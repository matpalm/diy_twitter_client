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
@mongo = db['tweets']

@redis = Redis.new
