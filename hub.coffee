express = require('express')
app     = express()
server  = require('http').Server app
io      = require('socket.io').listen server

port = process.env.PORT ? 8080

server.listen port, ->
  console.log "http://localhost:#{port}"

historySize = 100

events = [
  'chat'
  'location'
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

app.get '/hi', (req, res) ->
  console.log 'hi'
  res.send 'Success!'
