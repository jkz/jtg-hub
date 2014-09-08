conf = require('../conf').github
request = require 'request'
{feeds} = require '../feeds/github'

{per_page} = conf

api =
  options: (path, qs={}) ->
    json = true
    url = 'https://api.github.com' + path
    qs.client_id: conf.key
    qs.client_secret: conf.secret

    {url, qs, json, headers}

  get:  (args..., callback) ->
    reuest @options(args...), callback

  poll = (args..., callback) ->
    options = @options args...

    wrappedCallback = (err, {statusCode, headers}, body) ->
      if statusCode == 200
        options.headers['If-Last-Modified'] = headers['Last-Modified'] if headers['Last-Modified']?
        options.headers['If-None-Match'] = headers['ETag'] if headers['ETag']?
        callback(body, headers)

      setTimeout iter, 1000 * (parseInt(headers['X-Poll-Interval']) ? 0) ? conf.interval

    do iter = -> request options, wrappedCallback

api.poll "/users/#{conf.username}/events/public", {per_page}, (events) ->
  for event in data
    feed = switch event.type
      when 'IssuesEvent' then feeds.issue
      when 'CreateEvent' then feeds.create
      when 'WatchEvent' then feeds.watch
      when 'PushEvent' then feeds.push
    continue unless feed
    feed.add event

api.poll "/users/#{conf.username}/followers", {per_page}, (followers) ->
  feeds.followers.add follower for follower in followers

api.get "/users/#{conf.username}/repos", (err, repos) ->
  for repo in repos
    api.poll "/repos/#{repo.fullName}/stargazers", {per_page}, (stargazers) ->
      for stargazer in stargazers
        feeds.stargazers.add stargazer

module.exports = {api}
