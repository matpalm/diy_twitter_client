require 'rubygems'
require 'twitter'
require 'mongo'
require 'redis'
require 'redis_dbs'
require 'twitter_auth'
require 'core_exts'
require 'dereference_url_shorteners'

class Tweets

  def initialize
    @twitter = Twitter::Client.new

    mongo = Mongo::Connection.new
    db = mongo.db 'tweets'
    @tweets = db['tweets']
    @users = db['users']

    @redis = Redis.new
    @redis.select TWEET_DB

    @url_utils = DereferenceUrlShorteners.new
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
    friends = @twitter.friend_ids(uid)['ids'] rescue []
    user_info['friends'] = friends # TODO do some current users have wrong value, eg "[\"previous_cursor_str\", \"0\"]"
    @users.save user_info
    friends
  end

  def fetch_latest_tweets_for uid
    tweets = get_tweets_for uid
    new_tweets = tweets.select { |t| ! have_tweet? t['id'] }
    print "#{new_tweets.size} "
    new_tweets.each { |tweet| preprocess_and_store tweet }
  end

  def get_latest_unread
    # todo, how to sort by id with a find_one query?
    all_unread.sort(['id','descending']).limit(1).to_a.first
  end

  def all_read
    @tweets.find({ :read => true })
  end
  
  def all_unread
    @tweets.find({ :read => false })
  end

  def mark_thumbs_up tweet
    mark_read_prob tweet, 1.0, true
  end

  def mark_thumbs_down tweet
    mark_read_prob tweet, 0.0, true
  end

  def set_read_prob_but_leave_unread tweet, prob
    mark_read_prob tweet, prob, false
  end

  def tweets_marked_thumbs_up
    @tweets.find({ :read_prob => 1.0 })
  end
  def tweets_marked_thumbs_down
    @tweets.find({ :read_prob => 0.0 })
  end

  def stats 
    # todo use group by, (or bucketing when this get to be truely continuous, too lazy...
    {
      :read_prob => { 
        :"1"      => @tweets.find({ :read_prob => 1.0 }).count,
        :"0"      => @tweets.find({ :read_prob => 0.0 }).count,
      },
      :read   => all_read.count,
      :unread => all_unread.count,
      :total  => @tweets.find.count
    }
  end

  private

  def mark_read_prob tweet, prob, read
    tweet['read_prob'] = prob
    tweet['read'] = read
    @tweets.save tweet
  end

  def get_tweets_for uid
    opts = { :include_entities => true, :count => 100 }

    since_id = @redis.hget SINCE_ID, uid
    opts[:since_id] = since_id if since_id

    tweets = @twitter.user_timeline(uid, opts) #rescue []

    if tweets.size > 0
      max_id = tweets.map{|t| t['id']}.max
      @redis.hset SINCE_ID, uid, max_id
    end

    tweets.map(&:to_hash)
  end

  def have_tweet? id
    @tweets.find({:id => id}).count != 0
  end

  def preprocess_and_store tweet
    text_with_links_replaced_by_the_domains_they_point_at tweet
    tweet['read'] = false
    @tweets.insert tweet
  end

  def text_with_links_replaced_by_the_domains_they_point_at tweet
    sanitised_text = tweet['text'].clone

    tweet["entities"]["urls"].reverse.each do |url_info|
      url = url_info['url']
      target = @url_utils.final_target_of url
      target_domain = @url_utils.domain_of target
      sanitised_text.sub!(url, "[#{target_domain}]")
    end

    sanitised_text = sanitised_text.duplicate_whitespace_removed

    tweet['sanitised_text'] = sanitised_text
  end

end

