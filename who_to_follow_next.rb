#!/usr/bin/env ruby
require 'most_friended'

USAGE_INFO = <<EOF
usage:
who_to_follow_next.rb reset                  reset follow next and crawl queue
who_to_follow_next.rb add user1 user2 ...    add users to follow list
who_to_follow_next.rb step <num_steps>       num_steps times take the top entry and add their friends
who_to_follow_next.rb dump                   dump follow next queue and crawl queue  WARNING CAN GET HUGE FAST!
EOF

most_friended = MostFriended.new 
crawl_queue   = CrawlQueue.new

case ARGV[0]
when 'reset'
  most_friended.reset
  crawl_queue.reset

when 'add'
  ARGV.shift # add cmd
  ARGV.each { |uid| most_friended.add_user_with_screen_name uid }

when 'step'
  num_steps = ARGV[1].to_i
  raise USAGE_INFO unless num_steps
  num_steps.times do
    most_friended.add_top_friended
    # most_friended.add_least_friended
  end

when 'dump'
  most_friended.dump
  crawl_queue.dump

else
  raise USAGE_INFO

end

