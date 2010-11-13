#!/usr/bin/env ruby
require 'tweets'

client = Tweets.new

while true do
  tweets = client.get_latest_unread 5

  if tweets.empty?
    puts "no more left, go crawl some more sucka!"
    exit 0
  end

  tweets.each_with_index do |t, idx|
    id, text  = %w(id text).map{|k| t[k]}
    screen_name = t['user']['name']
    puts [idx, id, screen_name, text].join("\t")
  end

  idx = 0
  print "> "
  cmd = gets.chomp
  cmd.chars.to_a.each do |c|
    case c
    when 'u'
      client.mark_thumbs_up tweets[idx]
      idx += 1
    when 'd'
      client.mark_thumbs_down tweets[idx]
      idx += 1
    when 'n'
      client.mark_neutral tweets[idx]
      idx += 1
    when 'x'
      exit 0
    else 
      raise "don't know what [#{c}] means, sorry; expected one of [udnx]"
    end

  end

  puts client.stats.inspect

end




