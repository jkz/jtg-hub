stories = require '../providers/stories/feed'

host = ->
  stories.host()

user = ->
  null

all = ->
  host()
  user()

module.exports = {all, host, user}


