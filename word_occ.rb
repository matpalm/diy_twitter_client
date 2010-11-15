#!/usr/bin/env ruby
require 'set'
require 'tweets'

class WordOcc

  def initialize
    @tweets = Tweets.new
    @pos_tokens = Set.new
    @neg_tokens = Set.new
  end

  def load_training_egs
    @tweets.tweets_marked_thumbs_up.each do |tweet|
      @pos_tokens += tweet['text'].chomp.downcase.split
    end
    @tweets.tweets_marked_thumbs_down.each do |tweet|
      @neg_tokens += tweet['text'].chomp.downcase.split
    end
  end

  def classify_unrated_tweets
    @tweets.all_unread.each do |tweet|
      tweet_text = tweet['text'].chomp.downcase
      tokens = tweet_text.split
      pos = @pos_tokens.intersection(tokens).size
      neg = @neg_tokens.intersection(tokens).size
      to_read = pos > neg ? "+" : (pos < neg ? "-" : " ")
      puts "[#{to_read}] [#{tweet_text}] pos=#{pos} neg=#{neg}"      
    end
  end

  def dump
    puts "pos #{@pos_tokens.to_a.sort.inspect}"
    puts "neg #{@neg_tokens.to_a.sort.inspect}"
  end
  
end

wo = WordOcc.new
wo.load_training_egs
wo.classify_unrated_tweets

