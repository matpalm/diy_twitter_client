#!/usr/bin/env python
import pymongo
import itertools

connection = pymongo.Connection("localhost", 27017)
db = connection.tweets
unprocessed_tweets = db.tweets.find({'read':True})

for tweet in unprocessed_tweets:
    label = '1' if tweet['read_prob']==1.0 else '0'
    tag = 'id_' + str(tweet['id'])
    author = tweet['user']['screen_name']
    text = ' '.join(list(itertools.chain(*tweet['text_features']['tokens'])))

    print (label + ' ' + tag + '|author ' + author + ' |text ' + text).encode('utf-8')

