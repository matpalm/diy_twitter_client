#!/usr/bin/env ruby
require 'crawl_queue'
require 'dist_hash'
require 'tweets'

crawl_queue = CrawlQueue.new 
twitter = Tweets.new

# seed if required
if ! crawl_queue.contains? 'mat_kelcey'
  puts "empty? bootstrapping..."
  %w(mat_kelcey).each do |u| 
    crawl_queue.push(u) 
  end
  crawl_queue.dump_queue
end

# peek next
uid = crawl_queue.peek
puts "next is #{uid}"

# fetch tweets for users
tweets = twitter.fetch_latest_for :uid => uid
tweets.each do |tweet|
  puts "#{uid}\t#{tweet['id']}\t#{tweet['text']}"  
end

# readd to end
crawl_queue.push uid

# dump
crawl_queue.dump_queue
