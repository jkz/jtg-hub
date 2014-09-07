api = require 'soundclouder'
{models} = require 'feeds'
conf = require('../conf').soundcloud

class Feed extends models.JSONFeed
  prefix: '/soundcloud'

  generateTimestamp: ({created_at}) ->
    new Date(created_at).getTime()

class Aggregator extends models.Aggregator
  prefix: '/soundcloud'
  deserialize: JSON.parse

feeds =
  # follow: SoundcloudFeed.create 'follow'
  track: Feed.create 'track',
    generateId: ({origin}) -> origin.id
  share: Feed.create 'share',
    generateId: ({origin}) -> origin.track.id
  comment: Feed.create 'comment',
    generateId: ({origin}) -> origin.id
  favorite: Feed.create 'favorite',
    generateId: ({origin}) -> origin.track.id

  activities: Aggregator.create 'activities'

feeds.activities.combine feeds.track
feeds.activities.combine feeds.share
feeds.activities.combine feeds.comment
feeds.activities.combine feeds.favorite

api.init conf.key, conf.secret, conf.redirect_uri

pollUrl = null

do harvest = ->
  api.get (pollUrl ? '/me/activities/all/own'), conf.token, (err, response) -> #(err, {collection, future_href}={}) ->
    return if err

    console.log {err, response}
    {collection, future_href} = response

    for data in collection
      feed = switch data.type
        when 'track' then feeds.track
        when 'track-sharing' then feeds.share
        when 'comment' then feeds.comment
        when 'favoriting' then feeds.favorite

      continue unless feed

      feed.add data

    pollUrl = future_href if future_href

module.exports = {api, feeds, Feed, Aggregator}
