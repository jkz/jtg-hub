# TODO get from conf?
providers = [
  'twitter'
  'soundcloud'
  'github'
]

harvesters = {}
for provider in providers
  harvesters[provider] = require "./providers/#{provider}/harvest"

stories = ->
  harvester.stories() for _, harvester of harvesters

rewards = ->
  harvester.rewards() for _, harvester of harvesters

all = ->
  stories()
  rewards()

module.exports = {harvesters, stories, rewards, all}
