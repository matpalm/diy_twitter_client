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
    @tweets = db['tweets']
    @users = db['users']

    @redis = Redis.new
    @redis.select TWEET_DB
  end
  
  def client
    @twitter
  end

  def user_info_for uid
    mongo_lookup_key = uid.is_a?(String) ? 'screen_name' : 'id'
    user_info = @users.find_one(mongo_lookup_key => uid)
    return user_info if user_info
    user_info = @twitter.user(uid).to_hash    
    @users.save user_info
    user_info
  end

  def friends_of uid
    user_info = user_info_for uid
    return user_info['friends'] if user_info.has_key? 'friends'
    friends = @twitter.friend_ids(uid) rescue []
    user_info['friends'] = friends
    @users.save user_info
    friends
  end

  def fetch_latest_tweets_for uid
    tweets = get_tweets_for uid
    new_tweets = check_and_store_if_new tweets
    puts "num_fetched=#{tweets.size} num_new=#{new_tweets.size} num_total=#{@tweets.size}"
    new_tweets
  end

  def get_latest_unread n=10
    @tweets.find({ :thumbs => { "$exists" => false }}).limit(n).sort(['id','descending']).to_a
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
        :up        => @tweets.find({ :thumbs => 'up' }).count,
        :neutral   => @tweets.find({ :thumbs => 'neutral' }).count,
        :down      => @tweets.find({ :thumbs => 'down' }).count,
        :undecided => @tweets.find({ :thumbs => { "$exists" => false }}).count
      }
    }
  end

  private

  def mark mark, tweet
    tweet['thumbs'] = mark
    @tweets.save tweet
  end

  def get_tweets_for uid
    opts = { :include_entities=>true, :count => 20 }
    tweets = @twitter.user_timeline(uid, opts) rescue []
    tweets.map(&:to_hash)
  end

  def have_tweet? id
    @tweets.find({:id => id}).count != 0
  end

  def check_and_store_if_new tweets    
    unseen_tweets = tweets.select { |t| ! have_tweet? t['id'] }
    unseen_tweets.each do |t|
      @tweets.insert(t) 
    end
    unseen_tweets
  end

end

