#!/usr/bin/env ruby
require 'irb_rc'
require 'set'

=begin
s = Hash.new(0)
@tweets.find.each do |tweet|
  if tweet['state'] == 'fetched_from_twitter'
    s[:state__fetched_from_twitter2] += 1
    s[:err1] += 1 unless tweet['text_features'].has_key?('text_sans_url')

  elsif tweet['state'] == 'tokenized_text'
    s[:state__tokenized_text2] += 1
    s[:err2] += 1 if tweet['text_features'].has_key?('text_sans_url')
    s[:err3] += 1 unless tweet['text_features'].has_key?('tokens')

  else
    s[:state__unknown_state2] += 1

  end
#  @tweets.save tweet
end

pp s
=end