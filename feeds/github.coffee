{models} = require 'feeds'
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

  followers: Feed.create 'followers'
  stargazers: Feed.create 'stargazers'

  events: Aggregator.create 'events', deserialize: JSON.parse

feeds.events.combine feeds.create
feeds.events.combine feeds.issue
feeds.events.combine feeds.watch
feeds.events.combine feeds.push

module.exports = feeds
