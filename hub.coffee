express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server

app.use express.static __dirname + '/public'

[_command, _file, port] = process.argv

server.listen port

events = [
  'broadcast'
  'location'
]

io.sockets.on 'connection', (socket) ->
  for event in events
    do (event) ->
      socket.on event, (args...) ->
        io.sockets.emit event, args...
