require 'rubygems'
require 'twitter'

raise "not configured! need env vars! CONSUMER_KEY CONSUMER_SECRET OAUTH_TOKEN OAUTH_TOKEN_SECRET" unless ENV['CONSUMER_KEY']

Twitter.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.oauth_token = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end
