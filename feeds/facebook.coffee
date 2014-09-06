facebook = require 'facebook'
{JSONFeed, ComboFeed} = require 'feeds'

feeds =
  like: JSONFeed.create 'like'
  post: JSONFeed.create 'post'
  share: JSONFeed.create 'share'
  friend: JSONFeed.create 'friend'

  events: ComboFeed.create 'facebook'

module.exports = {api, feeds}
