#!/usr/bin/env ruby
require 'rubygems'
require 'redis'
require 'redis_dbs'
require 'crawl_queue'
require 'tweets'

STDOUT.sync = true

class MostFriended

  def initialize 
    @r = Redis.new
    @r.select FRIENDS_DB
    @t = Tweets.new
    @cq = CrawlQueue.new
  end

  def reset
    @r.flushdb
  end

  def dump
    puts "MostFriended.dump"

    puts "following..."
    puts @r.smembers(FOLLOWING).map(&:to_i).inspect

    puts "top 10 friends counts..."
    uids = @r.zrevrange FRIENDS_COUNT, 0, 10
    scores = uids.map { |uid| @r.zscore(FRIENDS_COUNT,uid).to_i }
    uids_as_ints = uids.map(&:to_i)
    puts uids_as_ints.zip(scores).inspect

    puts "bottom 5 friends counts..."
    uids = @r.zrange FRIENDS_COUNT, 0, 5
    scores = uids.map { |uid| @r.zscore(FRIENDS_COUNT,uid).to_i }
    uids_as_ints = uids.map(&:to_i)
    puts uids_as_ints.zip(scores).inspect

  end

  def add_user_with_screen_name screen_name
    add_user_with_id @t.user_info_for(screen_name)['id']
  end

  def add_followed_by_user_with_screen_name screen_name
    user = @t.user_info_for(screen_name)
    friends = @t.friends_of user['id']
    friends.each { |friend| add_user_with_id friend }
  end

  def add_top_friended
    add_user_with_id most_friended_user
  end

  def add_least_friended
    add_user_with_id least_friended_user
  end

  private

  def most_friended_user
    @r.zrevrange(FRIENDS_COUNT, 0, 0).first.to_i
  end

  def least_friended_user
    @r.zrange(FRIENDS_COUNT, 0, 0).first.to_i
  end

  def add_user_with_id uid
    return unless uid # empty set?
    screen_name = @t.user_info_for(uid)['screen_name']
    print "#{screen_name} "
    # remove them from further counting
    @r.zrem FRIENDS_COUNT, uid
    # push to crawler queue
    @cq.push_front screen_name
    # add to already-following set
    @r.sadd FOLLOWING, uid
    # get friends
    friends = @t.friends_of(uid.to_i)  
    # incr each friend as a candidate
    friends.each do |friend| 
      next if @r.sismember FOLLOWING, friend
      @r.zincrby FRIENDS_COUNT, 1, friend 
    end
  end

end

