#!/usr/bin/env ruby
require 'crawl_queue'
require 'tweets'

@crawl_queue = CrawlQueue.new 
@twitter = Tweets.new

STDOUT.sync = true
def fetch_next
  # peek next
  uid = @crawl_queue.peek
  print "#{uid} "
  
  # fetch tweets for users
  @twitter.fetch_latest_tweets_for uid

  # readd to end
  @crawl_queue.push uid
end

first_uid_processed = @crawl_queue.peek
last_uid_processed = nil
while last_uid_processed != first_uid_processed
  fetch_next
  last_uid_processed = @crawl_queue.peek
end

puts @twitter.stats.inspect
#puts "remaining_hits = #{@twitter.client.rate_limit_status['remaining_hits']}"
