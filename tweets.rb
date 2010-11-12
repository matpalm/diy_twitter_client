require 'rubygems'
require 'twitter'
require 'mongo'

raise "not configured! need env vars! CONSUMER_KEY CONSUMER_SECRET OAUTH_TOKEN OAUTH_TOKEN_SECRET" unless ENV['CONSUMER_KEY']

Twitter.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.oauth_token = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end

class Tweets

  def initialize
    @twitter = Twitter::Client.new

    mongo = Mongo::Connection.new
    db = mongo.db 'tweets'
    @mongo = db['tweets']
  end
  
  def fetch_latest_for opts
    tweets = get_tweets opts
    store tweets
    puts "mongo now has #{@mongo.size} unique tweets..."
    tweets
  end

  private

  def get_tweets opts
    raise "need :uid in opts" unless opts[:uid]
    uid = opts.delete :uid
    opts.merge!({ :trim_user => true, :count => 5 })
    tweets = @twitter.user_timeline(uid,  opts)
    tweets.map(&:to_hash)
  end

  def have_tweet? id
    @mongo.find({:id => id}).count != 0
  end

  def store tweets
    tweets.each do |t| 
      next if have_tweet? t['id']
      t['read'] = false
      @mongo.insert(t) 
    end
  end

end

