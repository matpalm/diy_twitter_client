#!/usr/bin/env ruby
require 'tweets'
require 'dereference_url_shorteners'
STDOUT.sync = true

@t = Tweets.new
@url_utils = DereferenceUrlShorteners.new

count = 0
@t.db.find({'text_features' => { '$exists' => false }}).each do |tweet|

  sanitised_text = tweet['text'].clone
  text_sans_url = tweet['text'].clone
  urls = Set.new

  tweet["entities"]["urls"].reverse.each do |url_info|
    url = url_info['url']
    target = @url_utils.final_target_of url
    target_domain = @url_utils.domain_of target
    sanitised_text.gsub!(url, "[#{target_domain}]")
    text_sans_url.gsub!(url, ' ')
    urls << target_domain
  end

  tweet['sanitised_text'] = sanitised_text.duplicate_whitespace_removed
  tweet['text_features'] = { 
    'text_sans_url' => text_sans_url.duplicate_whitespace_removed, 
    'urls' => urls.to_a
  }
  tweet['state'] = 'urls_dereferenced'

  @t.db.save tweet
  count += 1
  print "."
end

puts "processed #{count} tweets"

