Github = require 'github'
{models} = require 'feeds'
conf = require '../conf'

class Feed extends models.JSONFeed
  prefix: '/github'

  generateId: ({id}) ->
    id
  generateTimestamp: ({created_at}) ->
    new Date(created_at).getTime()

class Aggregator extends models.Aggregator
  prefix: '/github'
  deserialize: JSON.parse

feeds =
  create: Feed.create 'create'
  issue: Feed.create 'issue'
  watch: Feed.create 'watch'
  push: Feed.create 'push'

  events: Aggregator.create 'events', deserialize: JSON.parse

feeds.events.combine feeds.create
feeds.events.combine feeds.issue
feeds.events.combine feeds.watch
feeds.events.combine feeds.push

api = new Github version: '3.0.0'

api.authenticate
  type: "oauth"
  key: conf.github.key
  secret: conf.github.secret

lastModified = null

do harvest = ->
  api.events.getFromUser
    user: conf.github.user
    per_page: conf.github.per_page
    headers:
      'If-Modified-Since': lastModified
  , (err, data) ->
    setTimeout harvest, conf.github.interval
    return if err or data.meta.status == '304 Not Modified'
    lastModified = data.meta['last-modified']

    for event in data
      feed = switch event.type
        when 'IssuesEvent' then feeds.issue
        when 'CreateEvent' then feeds.create
        when 'WatchEvent' then feeds.watch
        when 'PushEvent' then feeds.push

      continue unless feed

      feed.add event

module.exports = {api, feeds, Feed, Aggregator}
