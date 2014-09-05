express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server
request = require('request')

port = process.env.PORT ? 8080

server.listen port, ->
  console.log "http://localhost:#{port}"

historySize = 100

identify = (token, done) ->
  request
    url: 'http://localhost:3000/users/me'
    headers:
      Authorization: token
    json: true
  , (err, res, body) ->
    done err, body

events = [
  'chat'
  #'location'
]

history =
  chat: []
  location: []

for event in events
  do (event) ->
    app.get "#{event}", (req, res) ->
      res.json history: history[event]

io.sockets.on 'connection', (socket) ->
  for event in events
    do (event) ->
      socket.on "#{event}.init", ->
        socket.emit "#{event}.history", history[event]

      app.get event, (req, res) ->
        res.json history: history[event]

      socket.on event, (payload) ->
        io.sockets.emit event, payload
        history[event] = [history[event]..., payload][0..historySize]

  socket.on 'auth', ({token}) ->
    identify token, (err, user) ->
      console.log "auth", err, user
      socket.user = user

  socket.on 'location', (coords) ->
    {user} = socket
    return console.log "NO AUTH", coords unless user
    console.log "LOCATION", {coords, user}
    io.sockets.emit 'location', {coords, user}

  socket.emit 'auth'

app.get '/hi', (req, res) ->
  console.log 'hi'
  res.send 'Success!'
