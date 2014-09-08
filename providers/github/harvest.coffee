request = require 'request'

conf  = require './conf'
feed = require './feed'

{per_page} = conf

headerRegex = /<([^>]+)>;\ rel="([^"]+)"/g

api =
  parseLinkHeader: (header) ->
    links = {}
    return links unless header
    for link in header.split ','
      match = headerRegex.exec link
      continue unless match
      [_, href, rel] = match
      links[rel] = href
    links

  options: (path, qs={}) ->
    json = true
    url = 'https://api.github.com' + path
    qs.client_id = conf.key
    qs.client_secret = conf.secret

    headers =
      'Accept': 'application/vnd.github.v3+json'
      'User-Agent': conf.host

    {url, qs, json, headers}

  get: (args..., callback) ->
    request @options(args...), (err, response, body) ->
      api.parseLinkHeader response.headers.link
      callback err, response, body


  all: (args..., callback) ->
    wrappedCallback = (err, {headers}, body) ->
      callback(body)

      {next} = api.parseLinkHeader headers.link

      request url: next, wrappedCallback if next

    request @options(args...), wrappedCallback

  poll: (args..., callback) ->
    options = @options args...

    wrappedCallback = (err, {statusCode, headers}, body) ->
      if statusCode == 200
        options.headers['If-Last-Modified'] = headers['last-modified'] if headers['last-modified']?
        options.headers['If-None-Match'] = headers['etag'] if headers['etag']?

        callback(body, headers)

      seconds = parseInt(headers['x-poll-interval'])
      seconds = conf.interval if isNaN seconds
      seconds = 10 if isNaN seconds

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

  stargaze = (repo) ->
    api.poll "/repos/#{repo}/stargazers", {per_page}, (stargazers) ->
      for stargazer in stargazers
        feed.user(stargazer.id).stargazers.add stargazer

  api.all "/users/#{conf.host}/repos", (repos) ->
    stargaze repo.fullName for repo in repos

  feed.host(conf.host).CreateEvent.on 'data', (data) ->
    stargaze data.fullName


module.exports = {api, stories, rewards}
