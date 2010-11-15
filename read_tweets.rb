#!/usr/bin/env ruby
require 'tweets'
require 'highline/system_extensions'
include HighLine::SystemExtensions

client = Tweets.new

puts "*** diy twitter client"
puts "*** u - thumbs up, d - thumbs down, n - neutral, x - exit"

puts client.stats.inspect

while true do
  tweet = client.get_latest_unread

  if tweet.nil?
    puts "no more left, go crawl some more sucka!"
    exit 0
  end
  
  # display tweet
  text = tweet['sanitised_text']
  time = Time.parse(tweet['created_at']).pretty
  printf "%-20s %-150s\n", time, text

  # read command
  cmd = get_character.chr
  case cmd
  when 'u'
    client.mark_thumbs_up tweet
  when 'd'
    client.mark_thumbs_down tweet
  when 'n'
    client.mark_neutral tweet
  when 'x'
    exit 0
  else 
    STDERR.puts "don't know what [#{c}] means, sorry; expected one of [udnx]"
  end

end




