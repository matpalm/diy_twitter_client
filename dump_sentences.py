#!/usr/bin/env python
import pymongo

connection = pymongo.Connection("localhost", 27017)
db = connection.tweets

for tweet in db.tweets.find({'text_features':{'$exists':True}}):
    if 'tokens' in tweet['text_features']:
        for sentence in tweet['text_features']['tokens']:
            print tweet['id'], ' '.join(sentence).encode('utf-8')
