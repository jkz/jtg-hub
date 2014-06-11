express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server

server.listen process.env.SOCKET_PORT

events = [
  'broadcast'
  'location'
]

io.sockets.on 'connection', (socket) ->
  for event in events
    do (event) ->
      socket.on event, (args...) ->
        io.sockets.emit event, args...
