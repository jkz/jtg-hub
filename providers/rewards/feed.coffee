conf = require '../../conf'
{models} = require 'feeds'

PREFIX = '/rewards'

# Reward feed filters all user stories on
class Feed extends models.JSONFeed
  prefix: PREFIX
  noStore: true

  dataKey: (id) ->
    id

  generateId: ({id}) ->
    id

  parse: ({id}) ->
    [_, provider, user_model, uid, model, object_id] = id.split '/'
    id = ref = "/#{provider}/#{model}/#{object_id}"
    {id, ref, provider, model, uid}

class Aggregator extends models.Aggregator
  prefix: PREFIX
  deserialize: JSON.parse

provider = (name) ->
  dest = Feed.create name
  feeds.all.combine dest

  src = require("../#{name}/feed")
  src.players.on 'data', dest.add

  dest

feeds =
  all: Aggregator.create 'all'

feeds[name] = provider name for name in conf.providers

module.exports = {feeds, provider, Feed, Aggregator}