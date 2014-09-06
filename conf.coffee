dotenv = require 'dotenv'
dotenv.load()

module.exports =
  port: process.env.PORT
  github:
    key: process.env.GITHUB_KEY
    secret: process.env.GITHUB_SECRET
    interval: parseInt(process.env.GITHUB_INTERVAL ? 10000)
    perPage: parseInt(process.env.GITHUB_PER_PAGE ? 10)
    user: 'jessethegame'
  redis:
    url: process.env.REDIS_URL ? process.env.REDISTOGO_URL ? process.env.REDISCLOUD_URL ? '127.0.0.1:6379'
  twitter:
    user: 'jessethegame'
    consumer:
      key: process.env.TWITTER_CONSUMER_KEY
      secret: process.env.TWITTER_CONSUMER_SECRET
    accessToken:
      key: process.env.TWITTER_ACCESS_TOKEN_KEY
      secret: process.env.TWITTER_ACCESS_TOKEN_SECRET

