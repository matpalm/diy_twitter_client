require 'rubygems'
require 'twitter'
require 'mongo'
require 'redis'
require 'redis_dbs'
require 'twitter_auth'

class Tweets

  def initialize
    @twitter = Twitter::Client.new

    mongo = Mongo::Connection.new
    db = mongo.db 'tweets'
    @mongo = db['tweets']

    @redis = Redis.new
    @redis.select TWEET_DB
  end
  
  def client
    @twitter
  end
  
  def fetch_latest_for opts
    tweets = get_tweets opts
    new_tweets = check_and_store_if_new tweets
    puts "num_fetched=#{tweets.size} num_new=#{new_tweets.size} num_total=#{@mongo.size}"
    new_tweets
  end

  def get_latest_unread n=10
    @mongo.find({ :read => false }).limit(n).sort(['id','descending'])
  end

  def save tweet
    @mongo.save tweet
  end

  def stats 
    # todo use group by, too lazy...
    {
      :num_unread => @mongo.find({ :read => false }).count,
      :num_read   => @mongo.find({ :read => true }).count,
    }
  end

  private

  def get_tweets opts
    raise "need :uid in opts" unless opts[:uid]
    uid = opts.delete :uid
    opts.merge!({ :include_entities=>true, :count => 10 })
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

