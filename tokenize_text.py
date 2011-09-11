#!/usr/bin/env python
import pymongo
from nltk.tokenize import WordPunctTokenizer, PunktWordTokenizer, PunktSentenceTokenizer

sent_tokenizer = PunktSentenceTokenizer()
token_tokenizer = WordPunctTokenizer()

connection = pymongo.Connection("localhost", 27017)
db = connection.tweets

# nltk splits on apostrophes; 
# eg "i don't care" => ["i","don","'","t","care"]
# this method recombines them
# eg => ["i","don't","care"]
# gets screwed by stuff like "i 'really' don't care", but to be honest, i really don't care :D
def recombine_apostrophes(a):
    b = []
    while len(a) > 0:
        next = a.pop(0)
        if next == "'" and len(b)>0 and len(a)>0:
            last_added = b.pop()
            next_to_add = a.pop(0)
            b.append(last_added + "'" + next_to_add)
        else:
            b.append(next)
    return b

def keep_token(token):
    return len(token)>1 or token.isalnum()

unprocessed_tweets = db.tweets.find({'state':'fetched_from_twitter'})
processed = 0
for tweet in unprocessed_tweets:
    text = tweet['text_features']['text_sans_url'].lower()
#    print "====================== ", tweet['id']
#    print "processing1 ", tweet['text']
#    print "processing2 ", text

    # need to remove urls
    tokens_without_urls = []
    for token in text.split(' '):
        if not (token.startswith('[') and token.endswith(']')):
            tokens_without_urls.append(token)
    text = ' '.join(tokens_without_urls)

    # extract user_mentions
    user_mentions = set()
    for user_mention in tweet['entities']['user_mentions']:
        screen_name = user_mention['screen_name'].lower()
        text = text.replace("@"+screen_name, '')
        user_mentions.add(screen_name)
#    print "post user_mention processing..."
#    print "text", text
#    print "user_mentions", user_mentions

    # and hashtags
    hashtags = set()
    for hashtag in tweet['entities']['hashtags']:
        hashtag_text = hashtag['text'].lower()
        text = text.replace("#"+hashtag_text, '')
        hashtags.add(hashtag_text)
#    print "post hashtag processing..."
#    print "text", text
#    print "hashtags", hashtags

    # tokenize text 
    tokens_per_sentence = [] # list of lists, list per sentence
    for sentence in sent_tokenizer.tokenize(text):
        tokens = token_tokenizer.tokenize(sentence)
        tokens = recombine_apostrophes(tokens)
        tokens = filter(keep_token, tokens)
        tokens_per_sentence.append(tokens) 

    # update tweet
    tweet['text_features'].pop('text_sans_url') 
    tweet['text_features']['user_mentions'] = list(user_mentions)
    tweet['text_features']['hashtags'] = list(hashtags)
    tweet['text_features']['tokens'] = tokens_per_sentence

#    print "text_features", tweet['text_features']

    tweet['state'] = 'tokenized_text'

    db.tweets.save(tweet)
    processed += 1

print "processed",processed,"tweets"

