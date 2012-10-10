# diy twitter client

## intro

a smart twitter client that learns what i like to read

goals
- learn more python & vowpal wabbit
- read more cool tweets

inspired by @hmason's [twitter client](https://github.com/hmason/tc)

## components

pipeline

get tweets:

either fetch based on crawl: twitter api -> mongodb (ruby, existing)

> ./fetch_new_tweets.rb

or fetch from sample

> curl -u user:password https://stream.twitter.com/1/statuses/sample.json | ./load_into_mongo.py

prep for tokenisation (dereference urls, sanitise text etc) (this was part of the original ruby version and could be folded into another step)
> ./pre_tokenise_processing.rb

preprocess: mongodb raw -> processing: url derefs; NLTK split

> ./tokenize_text.py
 
learn: 
 train with labelled data
  ? do we want to label just 0 & 1 or a range?
  what features to use?
  what cross features to do?
 set predicted label for unlabelled example
  ? might want to use raw values (ie those _not_ clipped to 0->1)
 
read:
 cli:
  show unlabelled tweets; order by predicted label; then time

 tweet in mongodb
  { 
   _twitter stuff_
   :dtc => {
    :predicted_label => [0.0, 1.0] # set if had been through prediction; if raw then -inf -> inf
    :actual_label => [0, 1]        # set if has been read   
   }
  }


## requirements

### deps

- mongodb; for storing raw tweets augmented with rating info
 sudo apt-get install mongodb
- redis; for the twitter crawling which for now is just tweets
 sudo apt-get install redis-server

- gem install mongo bson_ext  ; ruby mongo drivers
- gem install redis   ; ruby redis driver
- gem install twitter --pre ; primarily as an easier way to get around the pain that is oauth, need at least 1.0.0
-- ( requires libopenssl-ruby libssl-dev )
- gem install highline ; for superuber awesome cli!
- gem install curb     ; for url shortener unshortening ( requires libcurl3 libcurl3-gnutls libcurl4-openssl-dev )
- vowpal wabbit - 6.0 (though might just be using features from 5.1+)
- NLTK ; http://www.nltk.org/  python nl tokenisation
  
to install
- mongo db driver for python
 sudo easy_install pymongo
 https://github.com/mongodb/mongo-python-driver

i specifically DIDNT want to use the userstreaming timeline, find it more interesting
to deal with the raw tweets per person (particularly to pick up conversation stuff)

### setup

edit rc.eg.sh and add oauth creds for twitter, this need to be sourced into env for doing the crawl
very clumsy, best of luck working out what the hell to put in here (be grateful twitter doesnt expire app tokens!)
> $ source rc.sh

start mongo and redis
> $ ./start_mongod_and_redis.sh

### part one, who to crawl?

the system makes a simple decision of how who to collect tweets from.

firstly reset the follow/crawl queues with
> $ ./who_to_follow_next.rb reset

(note: this doesn't clear any cached tweets / user info / training data

add the people you follow as a bootstrap for the crawl queue
> $ ./who_to_follow_next.rb add_followed_by mat_kelcey

also add anyone else you want to explicity include (which may or may not include yourself)
this can be useful for seeding with some training data for tweets you DON'T want to read...
> $ ./who_to_follow_next.rb add mat_kelcey paris_hilton

at this stage, or maybe later, you can grow the crawl queue by adding other people to the crawl queue
a single step takes the most followed person to date and adds them to the crawl
(this needs a better explanation, this makes no sense and i wrote the code about an hour ago... just run it, it's awesome)
> $ ./who_to_follow_next.rb step 3

### part two, crawling some tweets

the crawling queue should have been set up by the ./who_to_follow_next.rb steps above,

once your happy with who you will crawl, then do some crawling!
this step fetches new tweets for everyone in the crawl queue

> $ ./fetch_new_tweets.rb
 - grabs latest tweets
 - dereferences urls

> $ ./tokenize_text.py
 - tokenizes text using nltk along with some other minor feature extraction
 
## random notes to be slotted in above

tweet #that @looks like [this.com]
 =>
|text tweet like |hashtags that |mentions looks |urls this.com

but want to include other namespace stuff too
|author mat_kelcey 
|reply (ie first mention)

will do cross products of various combos

#### an approach to tokenisation with entities in python

(though for learning without order this is not needed)

"text" => "*smile* I love it when @cloudera plugs our stuff, right @mike_schatz? http://bit.ly/dwENuP [graph algorithms with #Hadoop #MapReduce]"

 "entities"=>
  {"urls"=>"http://bit.ly/dwENuP",
   "hashtags"=>[{"text"=>"Hadoop", "indices"=>[114, 121]},{"text"=>"MapReduce", "indices"=>[122, 132]}],
   "user_mentions"=>["screen_name"=>"cloudera"}, "screen_name"=>"mike_schatz"}]},

in python convert to 

{ "_E1" => "@cloudera", "_E2" => "@mike_schatz", "_E3" => " http://bit.ly/dwENuP", "_E4" => "#Hadoop", "_E5" => "#MapReduce" } 
"text" => "*smile* I love it when _E1 plugs our stuff, right _E2? _E3 [graph algorithms with _E4 _E5]"

then split text to 

tokens  [u'*', u'smile', u'*', u'I', u'love', u'it', u'when', u'_E1', u'plugs', u'our', u'stuff', u',', u'right', u'_E2', u'?']
tokens  [u'_E3', u'[', u'graph', u'algorithms', u'with', u'_E4', u'_E5', u']']

and resub back in _E?'s



----------------------------------
-- old stuff down here 

i specifically DIDNT want to use the userstreaming timeline, find it more interesting
to deal with the raw tweets per person (particularly to pick up conversation stuff)

### part three: give some ratings

prep some training data by giving a thumbs up and thumbs down to unread tweets
> $ ./read_tweets.rb

you'll be presented with the latest unrated tweet
no username is given to ensure your opinion is not swayed :) 

for now the commands are...

- u: give thumbs up; this tweet is worth reading
- d: give thumbs down; this tweet is a waste of time
- x: exit

### part four: the actual learning

first version of a DEAD simple classifier based on word occurences is done...

> $ ./word_occ.rb

will check each unrated tweet and either give it [+] [-] or [ ]

## TODOs semi prioritised...
- convert word occurences to use redis (when required)
- determine, from model, what terms to search on; either the ones that are most related to read, least related or borderline...
- work out best way to hook the classified as to-read ones higher into the ./read_tweets queue
- make crawler not do a loop but instead stop when it gets to one that has time > process start time, can then run 2+ at same time (as long as pop next is atomic)
- expire friends list lookup, after a day/week/whatever should refetch
- work out how to have the author of highly rated tweets have their friends more likely to be added to the crawl 
- make crawl queue smarter, just round robin at the moment...
- decide on a feature breakdown; 1 feature per token, if_reply, has_link, has_at_references, num terms
- replace dead simple classifier with redis backed multinomial bayes
- white/black list of people to always read/ignore tweets from 

## NOTES TO SELF

for timeline api
https://github.com/jnunemaker/twitter/blob/master/lib/twitter/client/timeline.rb

mongo db ruby api
http://api.mongodb.org/ruby/1.1.2/index.html

