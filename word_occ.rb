#!/usr/bin/env ruby
require 'rubygems'
require 'redis'
require 'redis_dbs'

class WordOcc

  POS_COUNTS = 'pos'
  NEG_COUNTS = 'neg'

  def initialize
    @r = Redis.new
    @r.select THUMBS_DB
    @r.flushdb
  end

  def add_training_egs_from file
    File.open(file).each do |line|
      tokens = line.chomp.split
      pos_eg = (tokens.shift == '1')
      counts = pos_eg ? POS_COUNTS : NEG_COUNTS
      tokens.each do |token| 
        @r.hincrby counts, token, 1
      end
    end
  end

  def test_from file
    File.open(file).each do |line|
      line.chomp!
      puts "line #{line}"
      overall_score = 0.0
      num = 0
      puts ['p', 'n', 'p-n', 'p+n', 'sc', 'tok'].join("\t")
      line.split.each do |token|
        p = @r.hget(POS_COUNTS, token).to_i
        n = @r.hget(NEG_COUNTS, token).to_i
        next if p==0 && n==0 # term never seen before
        score = (p-n).to_f / (p+n)
        overall_score += score
        num += 1
        puts [p, n, p-n, p+n, sprintf("%3.3f",score), token].join("\t")
      end
      puts "score #{num==0?:'?':(overall_score/num)}"
    end
  end

  def dump
    pk,pv = @r.keys(POS_COUNTS), @r.vals(POS_COUNTS)
    puts pk.zip(pv).inspect
    nk,nv = @r.keys(NEG_COUNTS), @r.vals(NEG_COUNTS)
    puts nk.zip(nv).inspect
  end
  
end

wo = WordOcc.new
wo.add_training_egs_from('training')
wo.test_from('test')
