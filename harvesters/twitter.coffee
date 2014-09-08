twitter = require 'twitter'
{models} = require 'feeds'
conf = require('../conf').twitter

class Feed extends models.JSONFeed
  prefix: '/twitter'

  generateId: ({id}) ->
    id
  generateTimestamp: ({created_at}) ->
    new Date(created_at).getTime()

class Aggregator extends models.Aggregator
  prefix: '/twitter'
  # deserialize: JSON.parse

feeds =

  tweet: Feed.create 'tweet'
  follow: Feed.create 'follow'
  favorite: Feed.create 'favorite'

  user: Aggregator.create conf.user

feeds.user.combine feeds.tweet
feeds.user.combine feeds.follow
feeds.user.combine feeds.favorite

api = new twitter
  consumer_key: conf.consumer.key
  consumer_secret: conf.consumer.secret
  access_token_key: conf.accessToken.key
  access_token_secret: conf.accessToken.secret

api.stream 'filter', track: '#pizza', (stream) ->
  stream.on 'data', (data) ->
    feeds.tweet.add data if data.text

  stream.on 'follow', (follow) ->
    feeds.follow.add follow

  stream.on 'favorite', (favorite) ->
    feeds.favorite.add favorite

# api.stream 'user', track: conf.user, (stream) ->
#   stream.on 'data', (data) ->
#     console.log 'user', {data}

module.exports = {api, feeds, Feed, Aggregator}
