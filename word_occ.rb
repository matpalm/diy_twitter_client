#!/usr/bin/env ruby
require 'set'

class WordOcc

  def initialize
    @pos_counts = Hash.new(0)
    @neg_counts = Hash.new(0)
    @uniq_tokens = Set.new
  end

  def add_training_egs_from file
    File.open(file).each do |line|
      tokens = line.chomp.split
      pos_eg = (tokens.shift == '1')
      counts = pos_eg ? @pos_counts : @neg_counts
      tokens.each do |token| 
        counts[token] += 1
        @uniq_tokens << token
      end
    end
  end

  def info
    # be wary of items that have only +ve or only -ve
    @uniq_tokens.each do |token|
      p = @pos_counts[token]
      n = @neg_counts[token]
      score = (p-n).to_f / (p+n)
      puts [p, n, p-n, p+n, sprintf("%3.3f",score), token].join("\t")
    end
  end

  def dump
    puts @uniq_tokens.inspect
    puts @pos_counts.inspect
    puts @neg_counts.inspect
  end
  
end

wo = WordOcc.new
wo.add_training_egs_from('training')
wo.info
