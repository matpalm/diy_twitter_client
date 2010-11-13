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
    @mongo.find({ :thumbs => { "$exists" => false }}).limit(n).sort(['id','descending']).to_a
  end

  def mark_thumbs_up tweet
    mark 'up', tweet
  end

  def mark_thumbs_down tweet
    mark 'down', tweet
  end

  def mark_neutral tweet
    mark 'neutral', tweet
  end
  
  def stats 
    # todo use group by, too lazy...
    {
      :thumbs => { 
        :up        => @mongo.find({ :thumbs => 'up' }).count,
        :neutral   => @mongo.find({ :thumbs => 'neutral' }).count,
        :down      => @mongo.find({ :thumbs => 'down' }).count,
        :undecided => @mongo.find({ :thumbs => { "$exists" => false }}).count
      }
    }
  end

  private

  def mark mark, tweet
    tweet['thumbs'] = mark
    @mongo.save tweet
  end

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
      @mongo.insert(t) 
    end
    unseen_tweets
  end

end

