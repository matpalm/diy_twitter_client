#!/usr/bin/env ruby
require 'irb_rc'
if ARGV.length==1 && ARGV.first=='doit'
  @mongo.drop
  # todo: drop redis here
else
  warn "run with single arg doit to actually drop all data"
end
