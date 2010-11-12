#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'

mongo = Mongo::Connection.new
db = mongo.db 'tweets'
db = db['tweets']

db.find({ :read => { "$exists" => false }}).each do |tweet|
  tweet['read'] = false
  db.save(tweet)
end

