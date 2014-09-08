Twitter = require 'twitter'

conf = require './conf'
feed = require './feed'

# TODO we might want to pass in the host from the calling environment
#      rather than taking it from conf
{host} = conf

api = new Twitter
  consumer_key: conf.consumer.key
  consumer_secret: conf.consumer.secret
  access_token_key: conf.accessToken.key
  access_token_secret: conf.accessToken.secret

# stories = (host) ->
stories = ->
  feeds = feed.host(host)

  api.stream 'filter', track: host, (stream) ->
    stream.on 'data', (data) ->
      console.log 'tweet', data.id # {data}
      feeds.tweet.add data if data.text

    stream.on 'follow', (follow) ->
      console.log {follow}
      feeds.follow.add follow

    stream.on 'favorite', (favorite) ->
      console.log {favorite}
      feeds.favorite.add favorite

# rewards = (host) ->
rewards = ->
  api.stream 'user', track: host, (stream) ->
    stream.on 'data', (data) ->
      if data.target == host
        feed.user(data.source)[data.event]?.add data

      if data.retweeted_status?.user.screen_name == host
        feed.user(data.user_id).retweets.add data

module.exports = {api, stories, rewards}
