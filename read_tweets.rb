#!/usr/bin/env ruby
require 'tweets'
require 'string_exts'

client = Tweets.new

while true do
  tweets = client.get_latest_unread 5

  if tweets.empty?
    puts "no more left, go crawl some more sucka!"
    exit 0
  end

  tweets.each_with_index do |t, idx|
    id, text  = %w(id text).map{|k| t[k]}
    name = "#{t['user']['name']} (#{t['user']['screen_name']})"
#    printf "%2d - %-30s - %-150s\n", idx, name, text
    printf "%2d - %-150s\n", idx, text.duplicate_whitespace_removed
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




