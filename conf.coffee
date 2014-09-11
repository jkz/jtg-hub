dotenv = require 'dotenv'
dotenv.load()

module.exports = conf =
  env: process.env.NODE_ENV ? 'development'
  port: process.env.PORT

  providers: ['github', 'twitter', 'soundcloud']

  stories:
    host: 'jessethegame'

  redis:
    url: process.env.REDIS_URL ? process.env.REDISTOGO_URL ? process.env.REDISCLOUD_URL ? '127.0.0.1:6379'

  github:
    host: 'jessethegame'
    key: process.env.GITHUB_KEY
    secret: process.env.GITHUB_SECRET
    interval: parseInt(process.env.GITHUB_INTERVAL ? 10)
    perPage: parseInt(process.env.GITHUB_PER_PAGE ? 10)

  twitter:
    host: 'jessethegame'
    consumer:
      key: process.env.TWITTER_CONSUMER_KEY
      secret: process.env.TWITTER_CONSUMER_SECRET
    accessToken:
      key: process.env.TWITTER_ACCESS_TOKEN_KEY
      secret: process.env.TWITTER_ACCESS_TOKEN_SECRET

  soundcloud:
    host: 'jessethegame'
    key: process.env.SOUNDCLOUD_CLIENT_KEY
    secret: process.env.SOUNDCLOUD_CLIENT_SECRET
    token: process.env.SOUNDCLOUD_ACCESS_TOKEN
    redirect_uri: process.env.SOUNDCLOUD_REDIRECT_URI

  rewards:
    soundcloud:
      'track': 100
      'track-sharing': 100
      'comment': 100
      'favoriting': 100
    twitter:
      follow: 150
      unfollow: -150
      favorite: 100
      unfavorite: -100
    github:
      stargaze: 100
      follow: 150

if conf.env == 'development'
  conf.providers.push 'mock'
  conf.mock =
    host: 'jessethegame'
  conf.rewards.mock =
    foo: 100
    bar: -50