#!/usr/bin/env ruby
require 'tweets'
require 'core_exts'
require 'dereference_url_shorteners'

require 'highline/system_extensions'
include HighLine::SystemExtensions

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

puts "*** diy twitter client"
puts "*** u - thumbs up, d - thumbs down, n - neutral, x - exit"

while true do
  tweet = client.get_latest_unread

  if tweet.nil?
    puts "no more left, go crawl some more sucka!"
    exit 0
  end
  
  # display tweet
  text = text_with_links_replaced_by_the_domains_they_point_at tweet
  text = text.duplicate_whitespace_removed
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




