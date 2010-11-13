require 'rubygems'
require 'redis'
require 'redis_dbs'

class CrawlQueue

  def initialize reset=false
    @r = Redis.new
    @r.select CRAWL_QUEUE_DB
    clear if reset
  end

  def clear
    @r.zremrangebyrank Q, 0, queue_size
  end
  
  def contains? uid
    ! @r.zrank(Q, uid).nil?
  end

  def push uid
    @r.zadd Q, Time.now.to_f, uid
  end

  def peek
    @r.zrange(Q,0,0).first
  end

  def queue_size
    @r.zcard Q
  end

  def dump_queue
    puts ">dump"
    puts "there are #{queue_size} items in queue..."
    puts "next is #{peek} at #{@r.zscore(Q,peek)}"
    uids = @r.zrange Q, 0, queue_size
    scores = uids.map { |uid| @r.zscore(Q,uid) }
    puts uids.zip(scores).inspect
    puts "<dump"
  end

end

