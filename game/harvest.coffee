harvesters = {}

module.exports = (provider) ->
  return if harvesters[provider]
  harvester = harvesters[provider] = require "../providers/#{provider}/harvest"

  harvester.stories()
  harvester.rewards()
