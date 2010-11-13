#!/usr/bin/env ruby
require 'rubygems'
require 'redis'
require 'redis_dbs'
require 'crawl_queue'
require 'tweets'

USAGE_INFO = <<EOF
usage:
who_to_follow_next.rb reset_to <screen_name>  reset to this username
who_to_follow_next.rb step <num_steps>        num_steps times take the top entry and add their friends
who_to_follow_next.rb dump                    dump [[uid,count],[uid,count],...] WARNING CAN GET HUGE FAST!
EOF

@r = Redis.new
@r.select WHO_TO_FOLLOW_NEXT
@t = Tweets.new
@cq = CrawlQueue.new

def add_user uid
  screen_name = @t.user_info_for(uid)['screen_name']
  puts "adding #{screen_name}"
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

def add_top_followed
  # pop user who has the highest count of being a friend
  top = @r.zrevrange(FRIENDS_COUNT, 0, 0).first
  # remove them from further counting
  @r.zrem FRIENDS_COUNT, top
  # add as a user to crawl, and add their friends as candidate
  add_user top
end

case ARGV[0]
when 'reset_to'
  screen_name = ARGV[1]
  raise USAGE_INFO unless screen_name
  @r.flushdb  
  add_user @t.user_info_for(screen_name)['id']
when 'step'
  num_steps = ARGV[1].to_i
  raise USAGE_INFO unless num_steps
  num_steps.times { add_top_followed }
when 'dump'
  size = @r.zcard FRIENDS_COUNT
  uids = @r.zrevrange FRIENDS_COUNT, 0, size
  scores = uids.map { |uid| @r.zscore(FRIENDS_COUNT,uid) }
  uids.zip(scores).each do |uid,count|
    puts "#{uid.to_i}\t#{count.to_i}"
  end
else
  raise USAGE_INFO
end

