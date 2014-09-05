feeds = require 'feeds'
Github = require 'github'

conf = require './conf'

feed = feeds.models.create
  name: 'github'
  type: 'json'

feed.generateId = ({id}) -> id
feed.generateTimestamp = ({created_at}) -> -(new Date(created_at).getTime())

api = new Github
  version: '3.0.0'
  # protocol: 'http'
  # host: 'github.jessethegame.net'

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
    console.log {lastModified}
    feed.add event for event in data

module.exports = {feed, api}

