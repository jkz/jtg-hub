dotenv = require 'dotenv'
dotenv.load()

module.exports =
  port: process.env.PORT
  github:
    key: process.env.GITHUB_KEY
    secret: process.env.GITHUB_SECRET
    interval: parseInt(process.env.GITHUB_INTERVAL ? 10000)
    perPage: parseInt(process.env.GITHUB_PER_PAGE ? 10)
  redis:
    url: process.env.REDIS_URL ? process.env.REDISTOGO_URL ? process.env.REDISCLOUD_URL ? '127.0.0.1:6379'
