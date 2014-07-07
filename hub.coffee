express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server

port = process.env.PORT ? 8080

app.get '/', (req, res) ->
  res.send "Nothing to see here"

server.listen port, ->
  console.log 'listening', port

events = [
  'broadcast'
  'location'
]

io.sockets.on 'connection', (socket) ->
  for event in events
    do (event) ->
      socket.on event, (data) ->
        io.sockets.emit event, data

