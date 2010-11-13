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
    new_tweets = check_and_store_if_new tweets
    puts "fetched #{tweets.size} tweets (of which #{new_tweets.size} were new ones), mongo now has #{@mongo.size} unique tweets..."
    new_tweets
  end

  private

  def get_tweets opts
    raise "need :uid in opts" unless opts[:uid]
    uid = opts.delete :uid
    opts.merge!({ :trim_user => true, :count => 10 })
    tweets = @twitter.user_timeline(uid,  opts)
    tweets.map(&:to_hash)
  end

  def have_tweet? id
    @mongo.find({:id => id}).count != 0
  end

  def check_and_store_if_new tweets    
    unseen_tweets = tweets.select { |t| ! have_tweet? t['id'] }
    unseen_tweets.each do |t|
      t['read'] = false
      @mongo.insert(t) 
    end
    unseen_tweets
  end

end

