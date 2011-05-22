# source this in irb for hackery

require 'rubygems'
require 'twitter'
require 'mongo'
require 'redis'

require 'twitter_auth'
require 'redis_dbs'

require 'pp'

@twitter = Twitter::Client.new

mongo = Mongo::Connection.new
db = mongo.db 'tweets'
@tweets = db['tweets']
@users = db['users']
puts "#tweets #{@tweets.find.count} #users #{@users.find.count}"

@redis = Redis.new

require 'tweets'
@t = Tweets.new
pp @t.stats
