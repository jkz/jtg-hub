app     = require('express')()
server  = require('http').Server app
io      = require('socket.io').listen server
request = require('request')
feeds   = require('feeds')
github  = require('./github').feed

port = process.env.PORT ? 8080

app.use feeds.routes

server.listen port, ->
  console.log 'listening', port


chat = feeds.models.create name: 'chats'

chat.validate = (message) ->
  throw "No message" unless message

location = feeds.models.create name: 'locations', type: 'json', timeout: 120

location.validate = ({latitude, longitude}) ->
  throw "No latitude" unless location.latitude
  throw "No longitude" unless location.longitude
  throw "No user" unless location.user

identify = (token, done) ->
  request
    url: 'http://localhost:3000/users/me'
    headers:
      Authorization: token
    json: true
  , (err, res, body) ->
    {user} = body
    done err, user

io.sockets.on 'connection', (socket) ->
  socket.on 'auth', ({token}) ->
    identify token, (err, user) ->
      socket.user = user
      console.log name: user.name

  socket.on 'location', (coords) ->
    return unless socket.user
    {name, image} = socket.user
    user = {name, image}
    location.add {user, coords}

  socket.on 'location.init', ->
    console.log 'location.init'
    location
      .range()
      .then (history) ->
        socket.emit 'location.history', history
      .catch (err) ->
        console.log {err}

  socket.on 'chat', (message) ->
    console.log {message}
    chat.add message

  socket.on 'chat.init', ->
    console.log 'chat.init'
    chat
      .range()
      .then (history) ->
        socket.emit 'chat.history', history
      .catch (err) ->
        console.log {err}

  socket.on 'github.init', ->
    console.log 'github.init'
    github
      .range()
      .then (history) ->
        console.log {history}
        socket.emit 'github.history', history
      .catch (err) ->
        console.log {err}

  github.sub.on 'entry', ({entry}) ->
    socket.emit 'github', entry

  chat.sub.on 'entry', ({entry}) ->
    socket.emit 'chat', entry

  location.sub.socket 'entry', ({entry}) ->
    socket.emit 'location', entry

  socket.emit 'auth'
