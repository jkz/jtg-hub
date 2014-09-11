{models} = require 'feeds'

PREFIX = '/mock'

class Feed extends models.JSONFeed
  prefix: PREFIX

class Aggregator extends models.Aggregator
  prefix: PREFIX
  deserialize: JSON.parse

host = (id) ->
  prefix = PREFIX + '/hosts/' + id

  feeds =
    foo: Feed.create 'foo', {prefix}
    bar: Feed.create 'bar', {prefix}

  all = Aggregator.create 'all', {prefix}
  all.combine feed for _, feed of feeds
  feeds.all = all

  feeds

players = Aggregator.create 'players'

user = (id) ->
  prefix = PREFIX + '/users/' + id

  feeds =
    foo: Feed.create 'foo', {prefix}
    bar: Feed.create 'bar', {prefix}

  all = Aggregator.create 'all', {prefix}
  all.combine feed for _, feed of feeds
  feeds.all = all

  players.combine all

  feeds

module.exports = {host, user, players, Feed, Aggregator}
