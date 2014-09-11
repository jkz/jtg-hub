{models} = require 'feeds'

conf = require '../../conf'

{providers} = conf

PREFIX = '/stories'

class Aggregator extends models.Aggregator
  prefix: PREFIX

  deserialize: JSON.parse

  validate: (data) ->
    true

  render: ({id, data, timestamp}) =>
    # The id is of form /:provider[/:owner/:owner_id]/:model/:id
    [_, provider, owner..., model, id] = id.split '/'
    {provider, model, id, data, timestamp}

host = ->
  feeds =
    all: Aggregator.create 'all', prefix: PREFIX + '/hosts/' + conf.stories.host

  for provider in providers
    host = conf[provider].host
    feed = require("../#{provider}/feed").host(host).all

    do (provider) ->
      feed.on 'data', (data) ->
        console.log "STORIES RECEIVED A DATA", {provider}

    feeds[provider] = feed
    feeds.all.combine feed

  feeds

players = Aggregator.create 'players'

user = (id) ->
  feeds =
    all: Aggregator.create 'all', prefix: PREFIX + '/users/' + id

  players.combine feeds.all

  new User(id)
    .accounts()
    .then (accounts) ->
      for account in accounts
        {provider, id} = account
        feed = require("../#{provider}/feed").user(id).all
        feeds[provider] = feed
        feeds.all.combine feed

  feeds

module.exports = {user, host, players, Aggregator}
