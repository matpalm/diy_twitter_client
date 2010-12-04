#!/usr/bin/env ruby
require 'rubygems'
require 'redis'
require 'redis_dbs'
require 'curb'

class DereferenceUrlShorteners

  SHORTENERS = %(bit.ly goo.gl t.co j.mp is.gd su.pr slidesha.re qr.ae emc.im read.bi tcrn.ch)
  SHORT_TO_LONG = 'short_to_long'

  def initialize
    @r = Redis.new
    @r.select DEREFERENCE_URL_SHORTENERS_DB
  end

  def final_target_of url 
    return nil if url.nil? # probably a redirect to 404
    return url unless SHORTENERS.include? domain_of(url)
   
    target = check_cache(url)
    return target if target

    target = target_of_redirect(url)
    target = final_target_of target
    cache_redirect url, target
    target

  end

  def domain_of url
    return nil if url.nil?
    url.sub(%r{^.*?//}, '').sub(%r{/.*},'')
  end

  private

  def check_cache url
    @r.hget SHORT_TO_LONG, url
  end

  def cache_redirect url, target
    @r.hset SHORT_TO_LONG, url, target
  end

  def target_of_redirect url
    begin
      c = Curl::Easy.new url
      c.http_head
      redirect = c.header_str.match(/Location: (.*)/)
      return nil if redirect.nil?
      redirect[1].chomp
    rescue
      nil
    end
  end  
  
end

=begin
dus = DereferenceUrlShorteners.new
STDIN.each do |url|
  url.chomp!
  target = dus.final_target_of(url)
  domain = dus.domain_of target
  if url==target
    puts "untouched domain [#{domain}] url=[#{url}]"
  else
    puts "redirectd domain [#{domain}] url=[#{url}] target=[#{target}]"
  end
end
=end
