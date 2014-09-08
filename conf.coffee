dotenv = require 'dotenv'
dotenv.load()

module.exports =
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



