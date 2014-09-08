request = require 'request'

conf  = require './conf'
feed = require './feed'

{per_page} = conf

api =
  options: (path, qs={}) ->
    json = true
    url = 'https://api.github.com' + path
    qs.client_id = conf.key
    qs.client_secret = conf.secret

    headers =
      'Accept': 'application/vnd.github.v3+json'
      'User-Agent': conf.host

    {url, qs, json, headers}

  get:  (args..., callback) ->
    request @options(args...), callback

  poll: (args..., callback) ->
    options = @options args...

    wrappedCallback = (err, {statusCode, headers}, body) ->
      if statusCode == 200
        options.headers['If-Last-Modified'] = headers['last-modified'] if headers['last-modified']?
        options.headers['If-None-Match'] = headers['etag'] if headers['etag']?

        callback(body, headers)

      console.log {headers}

      seconds = parseInt(headers['x-poll-interval'])
      seconds = conf.interval if isNaN seconds
      seconds = 10 if isNaN seconds

      console.log {seconds}

      setTimeout iter, 1000 * seconds

    do iter = -> request options, wrappedCallback

stories = ->
  feeds = feed.host(conf.host)

  api.poll "/users/#{conf.host}/events/public", {per_page}, (events) ->
    for event in events
      feeds[event.type]?.add event

rewards = ->
  api.poll "/users/#{conf.host}/followers", {per_page}, (followers) ->
    for follower in followers
      feed.user(follower.id).followers.add follower

  api.get "/users/#{conf.host}/repos", (err, repos) ->
    for repo in repos
      api.poll "/repos/#{repo.fullName}/stargazers", {per_page}, (stargazers) ->
        for stargazer in stargazers
          feed.user(stargazer.id).stargazers.add stargazer

module.exports = {api, stories, rewards}
