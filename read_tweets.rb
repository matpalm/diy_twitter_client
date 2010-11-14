#!/usr/bin/env ruby
require 'tweets'
require 'string_exts'
require 'dereference_url_shorteners'

@url_utils = DereferenceUrlShorteners.new
client = Tweets.new

def text_with_links_replaced_by_the_domains_they_point_at tweet
  text = tweet['text']
  tweet["entities"]["urls"].reverse.each do |url_info|
    url = url_info['url']
    target = @url_utils.final_target_of url
    target_domain = @url_utils.domain_of(target)
    text.sub!(url, "[#{target_domain}]")
  end
  text
end

while true do
  tweets = client.get_latest_unread 5

  if tweets.empty?
    puts "no more left, go crawl some more sucka!"
    exit 0
  end

  tweets.each_with_index do |tweet, idx|
    id = tweet['id']
    text = text_with_links_replaced_by_the_domains_they_point_at tweet
    text = text.duplicate_whitespace_removed
    printf "%2d - %-150s\n", idx, text
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




