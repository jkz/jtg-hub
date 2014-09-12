express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server
request = require('request')
feeds   = require('feeds')
jwt     = require('jwt-simple')

bodyParser = require('body-parser')

app.use bodyParser.json()

conf = require './conf'

port = process.env.PORT ? 8080

# TODO for now to suppress the message
process.setMaxListeners(0)

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
  user = jwt.decode token, conf.jwt.secret, conf.jwt.algorithm
  console.log {user}
  user
  # request
  #   url: 'http://localhost:3000/users/me'
  #   headers:
  #     Authorization: token
  #   json: true
  # , (err, res, body) ->
  #   {user} = body
  #   done err, user

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
  console.log "chat", socket.user
  socket.on 'chat', (message) ->
    console.log 'chat', {message}
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


# Users
{User, Account} = require './models'

io.of('/users').on 'connection', (socket) ->
  console.log "JOIN USERS NAMESPACE"
  socket.on 'join', ({uid}) ->
    console.log "JOIN USERS ROOM", {uid}
    socket.join uid
  socket.on 'leave', ({uid}) ->
    console.log "LEAVE USERS ROOM", {uid}
    socket.leave uid

User.emitter.on 'new', (user) ->
  uid = user.id
  user.on 'data', ({type, data}) ->
    console.log 'user', {uid, type, data}
    io.of('/users').to(uid).emit 'data', {uid, type, data}


USER_ID = 3
USER = User.create(USER_ID)
ACCOUNTS =
  GITHUB:     Account.create('github', 'jessethegame')
  TWITTER:    Account.create('twitter', 'jessethegame')
  SOUNDCLOUD: Account.create('soundcloud', 'jessethegame')
  FACEBOOK:   Account.create('facebook', 'jessethegame')
  MOCK:       Account.create('mock', 'jessethegame')

acc.link USER_ID for _, acc of ACCOUNTS


# Feeds

expose = (feed, callback) ->
  routize feed
  socketize feed, callback

expose feed for _, feed of require('./game/feed').host()


# Harvest

harvest = require './game/harvest'

harvest 'github'
# harvest 'twitter'
# harvest 'soundcloud'

# Rewards

expose require('./game/reward').all()

# Mocks

if conf.env == 'development'
  mock =
    feed: require './providers/mock/feed'
    harvest: require './providers/mock/harvest'
  expose feed for _, feed of mock.feed.user 'jessethegame'
  app.use '/mock', mock.harvest.stories
  app.use '/mock', mock.harvest.rewards
