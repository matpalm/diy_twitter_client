#!/usr/bin/env ruby
require 'most_friended'

USAGE_INFO = <<EOF
usage:
who_to_follow_next.rb reset                                      reset follow next and crawl queue
who_to_follow_next.rb add <positive|negative> user1 user2 ...    add users to follow list
who_to_follow_next.rb step <num_steps>                           num_steps times take the top entry and add their friends
who_to_follow_next.rb dump                                       dump follow next queue and crawl queue  WARNING CAN GET HUGE FAST!
EOF

pos_most_friended = MostFriended.new POSITIVE_FRIENDS_DB
neg_most_friended = MostFriended.new NEGATIVE_FRIENDS_DB
crawl_queue       = CrawlQueue.new

case ARGV[0]
when 'reset'
  pos_most_friended.reset
  neg_most_friended.reset
  crawl_queue.reset

when 'add'
  ARGV.shift # add cmd
  db = ARGV.shift
  raise "expected add to either 'positive' or 'negative', not #{db}" unless ['positive','negative'].include?(db)  
  set = db=='positive' ? pos_most_friended : neg_most_friended
  ARGV.each { |uid| set.add_user_with_screen_name uid }

when 'step'
  num_steps = ARGV[1].to_i
  raise USAGE_INFO unless num_steps
  num_steps.times do
    pos_most_friended.add_top_friended
    # pos_most_friended.add_least_friended
    neg_most_friended.add_top_friended
    # neg_most_friended.add_least_friended
  end

when 'dump'
  pos_most_friended.dump
  neg_most_friended.dump
  crawl_queue.dump

else
  raise USAGE_INFO

end

