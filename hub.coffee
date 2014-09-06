app     = require('express')()
server  = require('http').Server app
io      = require('socket.io').listen server
request = require('request')
feeds   = require('feeds')

conf = require './conf'

port = process.env.PORT ? 8080

app.use feeds.routes

server.listen port, ->
  console.log 'listening', port

anonymous =
  name: 'Anon'
  image: 'http://placepu.gs/64/64'

# Allow multiple socket.io instances to be synced
ioRedis = require 'socket.io-redis'
io.adapter ioRedis conf.redis.url

# Expose a non-interactive feed
socketize = (feed, callback) ->
  namespace = io.of(feed.key)
  console.log namespace: feed.key

  namespace.on 'connection', (socket) ->
    log = (args...) ->
      console.log (socket.user ? anonymous).name, feed.name, args...

    log 'connection'
    socket.on 'init', ({pagination}={}) ->
      log 'init'
      feed
        .range(pagination)
        .then (history) ->
          log 'history'
          socket.emit 'history', history
        .catch (err) ->
          log 'history', {err}

    callback socket if callback

    socket.emit 'ready'

  feed.on 'entry', ({entry}) ->
    namespace.emit 'entry', entry

  namespace


## Authentication

identify = (token, done) ->
  request
    url: 'http://localhost:3000/users/me'
    headers:
      Authorization: token
    json: true
  , (err, res, body) ->
    {user} = body
    done err, user

io.on 'connection', (socket) ->
  socket.on 'auth', ({token}) ->
    identify token, (err, user) ->
      {name, image} = user
      socket.user = {name, image}
      console.log {name}

  socket.on 'logout', ->
    socket.user = null

## Chat

chat = feeds.models.JSONFeed.create 'chat',
  validate: (message) ->
    throw "No message" unless message

socketize chat, (socket) ->
  socket.on 'chat', (message) ->
    timestamp = new Date().getTime()
    user = socket.user ? anonymous
    chat.add {message, user, timestamp}

## Location

location = feeds.models.JSONFeed.create 'location',
  timeout: 120
  validate: ({latitude, longitude}) ->
    throw "No latitude" unless location.latitude
    throw "No longitude" unless location.longitude
    throw "No user" unless location.user

socketize location, (socket) ->
  socket.on 'location', (coords) ->
    return unless {user} = socket
    location.add {user, coords}


## Github

github = require('./feeds/github').feeds.events
socketize github

# Social
class SocialFeed extends feeds.models.ComboFeed
  deserialize: JSON.parse
  envelope: (id, data) ->
    [_, provider, model, id] = id.split '/'
    console.log {provider, model, id, data}
    {provider, model, id, data}

  find: (id) ->
    super(id).then (entry) =>
      @envelope id, entry

  entries: (ids) ->
    super(ids).then (entries) =>
      @envelope ids[i], entry for entry, i in entries

social = SocialFeed.create 'social'

social.combine github
socketize social

