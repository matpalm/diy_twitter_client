#!/usr/bin/env ruby
require 'rubygems'
require 'redis'
require 'redis_dbs'
require 'crawl_queue'
require 'tweets'

class MostFriended

  def self.valid_db? db
    ['positive','negative'].include? db
  end

  def initialize training_set
    raise "expected training_set of :positive or :negative" unless MostFriended.valid_db?(training_set)
    @training_set = training_set
    @r = Redis.new
    @r.select(@training_set=='positive' ? POSITIVE_FRIENDS_DB : NEGATIVE_FRIENDS_DB)
    @t = Tweets.new
    @cq = CrawlQueue.new
  end

  def reset
    @r.flushdb
  end

  def dump
    puts "MostFriended.dump #{@training_set}"

    puts "following..."
    puts @r.smembers(FOLLOWING).map(&:to_i).inspect

    puts "top 5 friends counts..."
    uids = @r.zrevrange FRIENDS_COUNT, 0, 5
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

  def add_top_friended
    add_user_with_id most_friended_user
  end

  def add_least_friended
    add_user_with_id least_friended_user
  end

  private

  def most_friended_user
    @r.zrevrange(FRIENDS_COUNT, 0, 0).first
  end

  def least_friended_user
    @r.zrange(FRIENDS_COUNT, 0, 0).first
  end

  def add_user_with_id uid
    screen_name = @t.user_info_for(uid)['screen_name']
    puts "adding #{screen_name}"
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

