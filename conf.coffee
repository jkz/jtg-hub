dotenv = require 'dotenv'
dotenv.load()

module.exports =
  port: process.env.PORT
  github:
    key: process.env.GITHUB_KEY
    secret: process.env.GITHUB_SECRET
    interval: parseInt(process.env.GITHUB_INTERVAL ? 10000)
    perPage: parseInt(process.env.GITHUB_PER_PAGE ? 10)
