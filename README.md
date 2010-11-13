# diy twitter client

## intro

a smart twitter client inspired by @hmason's [twitter client](https://github.com/hmason/tc)

goal is to hook it into [a semi supervised learning framework](http://matpalm.com/semi_supervised_naive_bayes/) i poked around with before 

only a day old so expect some SERIOUS WIPness!

## requirements

- redis; for the twitter crawling which for now is just tweets
- mongodb; for storing raw tweets augmented with rating info
- twitter gem; (gem install twitter)  https://github.com/jnunemaker/twitter

i specifically DIDNT want to use the userstreaming timeline, find it more interesting
to deal with the raw tweets per person (particularly to pick up conversation stuff)

edit rc.eg.sh and add oauth creds for twitter, this need to be sourced into env for doing the crawl
> $ source rc.sh

start mongo and redis
> $ ./start_mongod_and_redis.sh

### part one, who to crawl?

the system makes a simple decision of how who to collect tweets from.

firstly bootstrap with yourself as a candidate
> $ ./who_to_follow_next.rb reset_to mat_kelcey

next allow the system to walk your friend tree a bit to decide who else to the
crawl tweets of. one step is taking the candidate who has been seen as a friend
the most, add them to crawl queue, and add their friends to the list of candidates.
> $ ./who_to_follow_next.rb step 3

### part two, crawling some tweets

the crawling queue should have been set up by the ./who_to_follow_next.rb steps above,

if you want to add some people explicitly, eg hadoop and awscloud, you can run
> $ ./add_users_to_follow.rb hadoop awscloud

running ./add_users_to_follow.rb by itself has the cryptic side effect of showing you the 
crawl queue
> $ ./add_users_to_follow.rb

a similiar script can be used to remove people you are sick of seeing tweets from
(though really you'd be better off leaving them in for training data of what you DONT want to see!)
> $ ./remove_users_to_follow.rb PerezHilton britneyspears

once your happy with who you will crawl, then do some crawling
this step fetches new tweets for everyone in the crawl queue
> $ ./fetch_new_tweets.rb

### part three: give some ratings

prep some training data by giving a thumbs up and thumbs down to unread tweets
> $ ./read_tweets.rb

you'll be presented with the latest (upto) 5 tweets
give a single string that denotes what you think about each tweet

for now the commands are...
- u: thumbs up
- n: neutral
- d: thumbs down
- x: exit

eg 'uuudn' means you liked the first 3, didn't like the 4th and were neutral on the 5th

(i know it's a crap interface but it'll do for now)

## TODOs semi prioritised...
- use since_id in ./fetch_new_tweets.rb to avoid getting same tweets again and again
- make crawl queue smarter, just round robin at the moment...
- add something to read_tweets.rb that dereferences bitly links
- decide on a feature breakdown; 1 feature per token, if_reply, has_link, has_at_references, num terms
- hook up something dead simple for classification; even word occurences to start with
- hook up semi supervised version
- replace dead simple classifier with redis backed multinomial bayes

## NOTES TO SELF

for timeline api
https://github.com/jnunemaker/twitter/blob/master/lib/twitter/client/timeline.rb

mongo db ruby api
http://api.mongodb.org/ruby/1.1.2/index.html

