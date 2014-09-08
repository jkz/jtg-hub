{models} = require 'feeds'

PREFIX = '/github'

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
    CreateEvent: Feed.create 'create', {prefix}
    IssuesEvent: Feed.create 'issue', {prefix}
    WatchEvent: Feed.create 'watch', {prefix}
    PushEvent: Feed.create 'push', {prefix}

  all = Aggregator.create 'all', {prefix}
  all.combine feed for _, feed of feeds
  feeds.all = all

  feeds

user = (id) ->
  prefix = PREFIX + '/users/' + id

  feeds =
    followers: Feed.create 'followers', {prefix}
    stargazers: Feed.create 'stargazers', {prefix}

  all = Aggregator.create 'all', {prefix}
  all.combine feed for _, feed of feeds
  feeds.all = all

  feeds

module.exports = {host, user, Feed, Aggregator}
