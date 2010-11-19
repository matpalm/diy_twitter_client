#!/usr/bin/env ruby
require 'set'
require 'tweets'

class Array
  def mean
    inject(&:+).to_f / length
  end
end

class String
  def tokens
    chomp.downcase.split.map(&:to_sym)
  end
end

class WordOcc

  def initialize
    @tweets = Tweets.new
    reset
  end

  def reset
    @token_to_prob = {}
  end

  def train_from_read_tweets
    train_from_tweets @tweets.all_read
  end

  def train_from_unread_tweets
    train_from_tweets @tweets.all_unread
  end

  def classify_unread_tweets
    @tweets.all_unread.each do |tweet|
      prob = []
      tweet['sanitised_text'].tokens.each do |token|        
        if @token_to_prob.has_key? token
          prob << @token_to_prob[token].mean # try also prob += @token_to_prob
        else
          prob << 0.5
        end
      end
      @tweets.set_read_prob_but_leave_unread tweet, prob.mean
    end
  end

  def dump_prob_of_unread_tweets_to_file filename
    f = File.open(filename,'w')
    @tweets.all_unread.each do |t|
      cols = %w(id sanitised_text read_prob).map{|k|t[k]}
      f.puts cols.join("\t")
    end
    f.close
  end

  private
  
  def train_from_tweets tweets
    tweets.each do |tweet|
      text, read_prob = ['sanitised_text','read_prob'].map{|k|tweet[k]}
      text.tokens.each do |token|
        @token_to_prob[token] ||= []
        @token_to_prob[token] << read_prob
      end
    end
  end
  
end

model = WordOcc.new

puts Tweets.new.stats.inspect

puts "i1"
model.train_from_read_tweets
model.classify_unread_tweets
model.dump_prob_of_unread_tweets_to_file 'i1'

(2..5).each do |i|
  puts "i#{i}"
  model.reset
  model.train_from_read_tweets
  model.train_from_unread_tweets
  model.classify_unread_tweets
  model.dump_prob_of_unread_tweets_to_file "i#{i}"
end


=begin
while not model.converged? do
  model.reset
  model.train_from_read_tweets
  model.train_from_unread_tweets
  model.classify_unread_tweets
end
=end


