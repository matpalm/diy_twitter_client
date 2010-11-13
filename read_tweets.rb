#!/usr/bin/env ruby
require 'tweets'

client = Tweets.new

tweets = client.get_latest_unread 10
tweets.each do |t|
  puts "#{t['id']}\t#{t['user']['id']}\t#{t['text']}"
end
