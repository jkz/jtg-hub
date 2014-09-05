app     = require('express')()
server  = require('http').Server app
io      = require('socket.io').listen server
request = require('request')
feeds   = require('feeds')

port = process.env.PORT ? 8080

app.use feeds.routes

server.listen port, ->
  console.log "http://localhost:#{port}"


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
    done err, body

io.sockets.on 'connection', (socket) ->
  socket.on 'auth', ({token}) ->
    identify token, (err, user) ->
      socket.user = user

  socket.on 'location', (coords) ->
    {user} = socket
    location.add {user, coords}

  socket.on 'chat', (message) ->
    location.add message
