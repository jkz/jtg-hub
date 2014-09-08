feeds = require './feeds'

reward = (feed, value) ->
  feed.on 'data', (data) ->
    data.user.incr value

  feed.on 'undata', (data) ->
    data.user.decr value

rewards =
  follow: Feed.create 'follow'
  favorite: Feed.create 'favorite'
