{models} = require 'feeds'

PREFIX = '/twitter'

class Feed extends models.JSONFeed
  prefix: PREFIX

  generateId: ({id}) ->
    id
  generateTimestamp: ({created_at}) ->
    new Date(created_at).getTime()

class Aggregator extends models.Aggregator
  prefix: PREFIX
  deserialize: JSON.parse

host = (id) ->
  prefix = PREFIX + '/hosts/' + id

  feeds =
    tweet:    Feed.create 'tweet'
    follow:   Feed.create 'follow'
    favorite: Feed.create 'favorite'

  all = Aggregator.create 'all', {prefix}
  all.combine feed for _, feed of feeds
  feeds.all = all

  feeds

players = Aggregator.create 'players'

user = (id) ->
  prefix = PREFIX + '/users/' + id

  feeds =
    follow:     Feed.create 'follow', {prefix}
    unfollow:   Feed.create 'unfollow', {prefix}
    favorite:   Feed.create 'favorite', {prefix}
    unfavorite: Feed.create 'unfavorite', {prefix}

  all = Aggregator.create 'all', {prefix}
  all.combine feed for _, feed of feeds
  feeds.all = all

  players.combine all

  feeds

module.exports = {host, user, players, Feed, Aggregator}
