set -ex

export MONGO_DB=/data2/mongodb/twitter_client
if [ ! -d $MONGO_DB ]; then mkdir $MONGO_DB; fi
mongod --dbpath=$MONGO_DB >mongodb.out 2>&1 &

redis-server >redis.out 2>&1 &

ps aux | grep "redis\|mongo"