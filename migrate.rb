#!/usr/bin/env ruby
require 'irb_rc'
require 'set'

@tweets.find('state' => 'fetched_from_twitter').each do |t|
  t['state'] = 'urls_dereferenced'
#  @t.text_with_links_replaced_by_the_domains_they_point_at t#['state'] = 'fetched_from_twitter'
  @tweets.save t
end

=begin

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
