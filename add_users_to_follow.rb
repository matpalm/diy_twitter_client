#!/usr/bin/env ruby
require 'crawl_queue'
crawl_queue = CrawlQueue.new 
ARGV.each { |screen_name| crawl_queue.push(screen_name) }


