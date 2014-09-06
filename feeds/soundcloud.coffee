soundcloud = require 'soundcloud'
{JSONFeed, ComboFeed} = require 'feeds'

feeds =
  love: JSONFeed.create 'love'
  track: JSONFeed.create 'track'
  follow: JSONFeed.create 'follow'

module.exports = {api, feeds}
