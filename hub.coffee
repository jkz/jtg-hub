express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server
request = require('request')
feeds   = require('feeds')

conf = require './conf'

port = process.env.PORT ? 8080

# app.use feeds.routes

server.listen port, ->
  console.log 'listening', port

anonymous =
  name: 'Anon'
  image: 'http://placepu.gs/64/64'

# Allow multiple socket.io instances to be synced
ioRedis = require 'socket.io-redis'
io.adapter ioRedis conf.redis.url

# Add urls
routize = (feed) ->
  {resource, middleware} = feeds

  path = feed.key

  console.log routize: path

  routes = express()
  routes.get '/', [
    middleware.pagination.range
  ], resource.show
  routes.post '/', resource.add
  routes.get '/:entry', resource.find

  app.use path, (req, res, next) ->
    req.feed = feed
    next()
  app.use path, routes

# Expose a non-interactive feed
socketize = (feed, callback) ->
  namespace = io.of(feed.key)

  console.log socketize: feed.key

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

  feed.on 'data', ({render}) ->
    namespace.emit 'data', render

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
  # socket.on 'auth', ({token}) ->
  #   identify token, (err, user) ->
  #     {name, image} = user
  #     socket.user = {name, image}
  #     console.log {name}

  #     socket.emit 'login', user

  socket.on 'login', (user) ->
    # socket.user = user
    console.log "LOGIN", {user}
    anonymous = user
    socket.emit 'login', user

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

# location = feeds.models.JSONFeed.create 'location',
#   timeout: 120
#   validate: ({latitude, longitude, user}) ->
#     throw "No latitude" unless latitude
#     throw "No longitude" unless longitude
#     throw "No user" unless user
#
# socketize location, (socket) ->
#   socket.on 'location', (coords) ->
#     return unless {user} = socket
#     location.add {user, coords}

lastLocation = user: anonymous, coords: {}

io.of('/location')
  .on 'connection', (socket) ->
    socket.on 'location', (coords) ->
      user = socket.user ? anonymous
      lastLocation = {coords, user}
      # return unless {user} = socket
      io.of('/location').emit 'location', {user, coords}

    socket.emit 'location', lastLocation


# Feeds

expose = (feed, callback) ->
  routize feed
  socketize feed, callback

expose feed for _, feed of require('./feed').host()



# Harvest

require('./harvest').all()


# Rewards

# feeds.rewards.on 'data', (reward) ->
#   io.of("/users/#{reward.user}").emit 'reward', reward

