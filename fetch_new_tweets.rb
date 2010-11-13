#!/usr/bin/env ruby
require 'crawl_queue'
require 'tweets'

@crawl_queue = CrawlQueue.new 
@twitter = Tweets.new

# seed if required
if ! @crawl_queue.contains? 'mat_kelcey'
  puts "empty? bootstrapping..."
  %w(mat_kelcey).each do |u| 
    @crawl_queue.push(u) 
  end
  @crawl_queue.dump_queue
end

def fetch_next
  # peek next
  uid = @crawl_queue.peek
  puts "next is #{uid}"
  
  # fetch tweets for users
  tweets = @twitter.fetch_latest_for :uid => uid
  tweets.each do |tweet|
    puts "#{uid}\t#{tweet['id']}\t#{tweet['text']}"  
  end

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
