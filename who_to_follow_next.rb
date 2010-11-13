#!/usr/bin/env ruby
require 'rubygems'
require 'redis'
require 'redis_dbs'

require 'twitter'
require 'twitter_auth'

@r = Redis.new
@r.select WHO_TO_FOLLOW_NEXT
@r.flushdb

@t = Twitter::Client.new

def add_user screen_name

  puts "adding #{screen_name}"

  # add to following set
  @r.sadd FOLLOWING, screen_name

  # get friends
  friends = @t.friend_ids screen_name
  
  # incr each friend
  friends.each do |friend| 
    @r.zincrby FRIENDS_COUNT, 1, friend 
  end

end

def dump
  size = @r.zcard FRIENDS_COUNT
  uids = @r.zrevrange FRIENDS_COUNT, 0, size
  uids = uids.slice(0,10)
  scores = uids.map { |uid| @r.zscore(FRIENDS_COUNT,uid) }
  uids.zip(scores).each { |us| puts us.inspect }
end

def top_followed
  @r.zrange(FRIENDS_COUNT, 0, 0).first
end


add_user 'mat_kelcey'
dump

add_user 'neilkod'
dump
