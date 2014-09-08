api = require 'soundclouder'

conf = require './conf'
feed = require './feed'

api.init conf.key, conf.secret, conf.redirect_uri

pollUrl = null

stories = ->
  api.get (pollUrl ? '/me/activities/all/own'), conf.token, (err, response) -> #(err, {collection, future_href}={}) ->
    return if err

    {collection, future_href} = response

    for data in collection
      feed.host(conf.host)[data.type]?.add data

    pollUrl = future_href if future_href

rewards = ->
  null

module.exports = {api, stories, rewards}
