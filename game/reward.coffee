conf = require '../conf'

{feeds} = require '../providers/rewards/feed'

Account = require '../models/Account'

all = ->
  feeds.all.on 'data', ({data}) ->
    {ref, uid, provider, model} = data

    value = conf.rewards[provider]?[model]
    return unless value

    Account
      .create(provider, uid)
      .user()
      .then (user) ->
        user.transaction {ref, value}
      .then (transaction) ->
        console.log {transaction}
      .catch (err) ->
        console.log {err}

  feeds.all

module.exports = {all}
