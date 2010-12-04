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

substituted_entities = {}
entity_index = 0
def replace_snippet_with_entity_marker(text, snippet):
    global entity_index
    global substituted_entities
    marker = "__ENTITY%d" % (entity_index)
    entity_index += 1
    substituted_entities[marker] = snippet
    return text.replace(snippet, marker)

def resubtitute_entities_back_in(token):
    global substituted_entities
    return substituted_entities[token] if substituted_entities.has_key(token) else token

untokenized_tweets = db.tweets.find({"text_tokens":{"$exists":False}})
processed = 0
for tweet in untokenized_tweets:
    text = tweet['text']

    # substitute out various types of entities
    for user_mention in tweet['entities']['user_mentions']:
        screen_name = "@" + user_mention['screen_name']
        text = replace_snippet_with_entity_marker(text, screen_name)
    for hashtag in tweet['entities']['hashtags']:
        hash_tag = "#" + hashtag['text']
        text = replace_snippet_with_entity_marker(text, hash_tag)
    for url_info in tweet['entities']['urls']:
        url = url_info['url']
        text = replace_snippet_with_entity_marker(text, url)

    # tokenize and clean up a bit
    tokens_per_sentence = [] # list of lists, list per sentence
    for sentence in sent_tokenizer.tokenize(text):
        tokens = token_tokenizer.tokenize(sentence)
        tokens = recombine_apostrophes(tokens)
        tokens = filter(keep_token, tokens)
        tokens = map(resubtitute_entities_back_in, tokens)
        tokens_per_sentence.append(tokens)
    
    # update tweet
    tweet['text_tokens'] = tokens_per_sentence
    db.tweets.save(tweet)
    processed += 1

print "processed",processed,"tweets"

