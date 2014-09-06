twitter = require 'twitter'
{JSONFeed, ComboFeed} = require 'feeds'

feeds =
  tweet: JSONFeed.create 'tweet'
  retweet: JSONFeed.create 'retweet'
  follow: JSONFeed.create 'follow'

module.exports = {api, feeds}
