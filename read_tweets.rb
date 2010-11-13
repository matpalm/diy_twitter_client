#!/usr/bin/env ruby
require 'tweets'

client = Tweets.new

tweets = client.get_latest_unread 10

tweets.each do |t|
  id, text, read  = %w(id text read).map{|k| t[k]}
  screen_name = t['user']['name']
  puts [id, read, screen_name, text].join("\t")
end

puts client.stats.inspect
