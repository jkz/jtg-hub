{models} = require 'feeds'

PREFIX = '/soundcloud'

class Feed extends models.JSONFeed
  prefix: PREFIX

  generateTimestamp: ({created_at}) ->
    new Date(created_at).getTime()

class Aggregator extends models.Aggregator
  prefix: PREFIX
  deserialize: JSON.parse

host = (id) ->
  prefix = PREFIX + '/hosts/' + id

  feeds =
    # follow: SoundcloudFeed.create 'follow'
    'track': Feed.create 'track',
      prefix: prefix
      generateId: ({origin}) -> origin.id
    'track-sharing': Feed.create 'share',
      prefix: prefix
      generateId: ({origin}) -> origin.track.id
    'comment': Feed.create 'comment',
      prefix: prefix
      generateId: ({origin}) -> origin.id
    'favoriting': Feed.create 'favorite',
      prefix: prefix
      generateId: ({origin}) -> origin.track.id

  all = Aggregator.create 'all', {prefix}
  all.combine feed for _, feed of feeds
  feeds.all = all

  feeds

players = Aggregator.create 'players'

user = (id) ->
  null

module.exports = {host, user, players, Feed, Aggregator}
