#!/usr/bin/env python
import pymongo
import itertools

connection = pymongo.Connection("localhost", 27017)
db = connection.tweets
unprocessed_tweets = db.tweets.find({'read':True}) #.limit(4)


for tweet in unprocessed_tweets:
    record = ""
    
    # label
    if tweet['read_prob']==1.0:
        record += '1' 
    else:
        record += '0'
    
    # tag
    record += ' id_' + str(tweet['id'])

    # author
    record += '|author ' + tweet['user']['screen_name']

    # optional breakdown of tweet text
    text = list(itertools.chain(*tweet['text_features']['tokens']))
    if len(text)>0:
        record += ' |text ' + ' '.join(text)
    um = tweet['text_features']['user_mentions']
    if len(um)>0:
        record += ' |mentions ' + ' '.join(um)
    ht = tweet['text_features']['hashtags']
    if len(ht)>0:
        record += ' |hashtags ' + ' '.join(ht)
    urls = tweet['text_features']['urls']
    if len(urls)>0:
        record += ' |urls ' + ' '.join(urls)
                      
    print record.encode('utf-8')

