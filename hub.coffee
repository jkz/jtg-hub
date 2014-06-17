express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server

server.listen process.env.PORT ? 8080

historySize = 100

events = [
  'chat'
  'location'
]

history =
  chat: []
  location: []

io.sockets.on 'connection', (socket) ->
  for event in events
    do (event) ->
      socket.on 'init', ->
        socket.emit "history.#{event}", history[event]

      socket.on event, (payload) ->
        io.sockets.emit event, payload
        history[event] = [payload, history[event]...][0..historySize]
