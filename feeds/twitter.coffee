twitter = require 'twitter'
{JSONFeed, ComboFeed} = require 'feeds/feeds/models'
conf = require('../conf').twitter

class TwitterFeed extends JSONFeed
  @prefix: '/twitter'

  generateId: ({id}) ->
    id
  generateTimestamp: ({created_at}) ->
    new Date(created_at).getTime()

feeds =
  tweet: TwitterFeed.create 'tweet'
  # retweet: JSONFeed.create 'retweet'
  follow: TwitterFeed.create 'follow'
  user: ComboFeed.create conf.user

feeds.user.combine feeds.tweet
# feeds.user.combine feeds.retweet
feeds.user.combine feeds.follow
feeds.user.combine feeds.tweet

api = new twitter
  consumer_key: conf.consumer.key
  consumer_secret: conf.consumer.secret
  access_token_key: conf.accessToken.key
  access_token_secret: conf.accessToken.secret

api.stream 'filter', track: '#pizza', (stream) ->
  stream.on 'data', (data) ->
    feeds.tweet.add data if data.text

# api.stream 'user', track: conf.user, (stream) ->
#   stream.on 'data', (data) ->
#     console.log 'user', {data}

module.exports = {api, feeds}
