# diy twitter client

## intro

a smart twitter client inspired by @hmason's [twitter client](https://github.com/hmason/tc)

goal is to hook it into [a semi supervised learning framework](http://matpalm.com/semi_supervised_naive_bayes/) i poked around with before 

## requirements

- redis; for the twitter crawling which for now is just tweets
- mongodb; for storing raw tweets augmented with rating info
- gem install mongo bson_ext  ; mongo drivers
- gem install redis   ; redis driver
- gem install twitter --pre ; primarily as an easier way to get around the pain that is oauth, need at least 1.0.0
-- ( requires libopenssl-ruby libssl-dev )
- gem install highline ; for superuber awesome cli!
- gem install curb     ; for url shortener unshortening ( requires libcurl3 libcurl3-gnutls libcurl4-openssl-dev )


i specifically DIDNT want to use the userstreaming timeline, find it more interesting
to deal with the raw tweets per person (particularly to pick up conversation stuff)

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

add some people to look at the tweets of
> $ ./who_to_follow_next.rb add positive hadoop peteskomoroch mrflip

walk the twitter friend graph a bit to decide who else to crawl tweets of. 
a single step takes the most/least friended of the positive/negative set and adds them to the crawl (ie 4 new users to crawl)

(this needs a better explanation, this makes no sense and i wrote the code about an hour ago... just run it, it's awesome)
> $ ./who_to_follow_next.rb step 3

### part two, crawling some tweets

the crawling queue should have been set up by the ./who_to_follow_next.rb steps above,

once your happy with who you will crawl, then do some crawling!
this step fetches new tweets for everyone in the crawl queue
> $ ./fetch_new_tweets.rb

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

