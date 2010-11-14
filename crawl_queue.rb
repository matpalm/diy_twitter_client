require 'rubygems'
require 'redis'
require 'redis_dbs'

class CrawlQueue

  def initialize 
    @r = Redis.new
    @r.select CRAWL_QUEUE_DB
  end

  def reset
    @r.flushdb
  end

  def contains? screen_name
    ! @r.zrank(CRAWL_QUEUE, screen_name).nil?
  end

  def push screen_name
    @r.zadd CRAWL_QUEUE, Time.now.to_f, screen_name 
  end

  def push_front screen_name
    @r.zadd CRAWL_QUEUE, 1.0, screen_name
  end

  def remove screen_name
    @r.zrem CRAWL_QUEUE, screen_name
  end

  def peek
    @r.zrange(CRAWL_QUEUE,0,0).first
  end

  def queue_size
    @r.zcard CRAWL_QUEUE
  end

  def dump
    puts "CrawlQueue.dump"
    screen_names = @r.zrange CRAWL_QUEUE, 0, queue_size
    scores = screen_names.map { |screen_name| @r.zscore(CRAWL_QUEUE,screen_name) }
    puts screen_names.zip(scores).inspect
  end

end

