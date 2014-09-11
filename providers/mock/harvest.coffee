express = require 'express'
feed    = require './feed'

stories = express()

stories.post '/hosts/:id/foo', (req, res) ->
  feed.host(req.params.id).foo
    .add req.body
    .then (response) ->
      res.json response
    .done()
    # .catch (error) ->
    #   res.json {error}

stories.post '/hosts/:id/bar', (req, res) ->
  feed.host(req.params.id).bar
    .add req.body
    .then (response) ->
      res.json response
    .done()
    # .catch (error) ->
    #   res.json {error}

rewards = express()

rewards.post '/users/:id/foo', (req, res) ->
  feed.user(req.params.id).foo
    .add req.body
    .then (response) ->
      res.json response
    .done()
    # .catch (error) ->
    #   res.json {error}

rewards.post '/users/:id/bar', (req, res) ->
  feed.user(req.params.id).bar.add req.body
    .then (response) ->
      res.json response
    .done()
    # .catch (error) ->
    #   res.json {error}

module.exports = {stories, rewards}