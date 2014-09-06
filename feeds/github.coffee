Github = require 'github'

{JSONFeed, ComboFeed} = require 'feeds/feeds/models'

conf = require '../conf'

class GithubFeed extends JSONFeed
  @prefix: '/github'

  generateId: ({id}) ->
    id
  generateTimestamp: ({created_at}) ->
    new Date(created_at).getTime()

feeds =
  create: GithubFeed.create 'create'
  issue: GithubFeed.create 'issue'
  watch: GithubFeed.create 'watch'
  push: GithubFeed.create 'push'

  events: ComboFeed.create 'github', deserialize: JSON.parse

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
    user: 'jessethegame'
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

module.exports = {feeds, api}
