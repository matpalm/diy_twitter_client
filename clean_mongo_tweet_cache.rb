#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
Mongo::Connection.new.db('tweets')['tweets'].drop
