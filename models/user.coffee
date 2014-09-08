{models} = require 'feeds'
events = require 'events'

db = require '../db'

class User extends events.EventEmitter
  @create: (name, options) ->
    null

  constructor: (@name, options) ->
    for key, val of options
      this[key] = val

    @db ?= db
    @key ?= @prefix + @name
    @transactionsKey ?= @key + '/transactions'
    @accountKey ?= @key + '/accounts'

  accounts: =>
    @db.hgetall @accountKey
      .then (accounts) ->
        {provider, id} for provider, id of accounts

  connectAccount: (provider, id) =>
    @db.hset @accountKey, provider, id

  disconnectAccount: (provider) =>
    @db.hdel @accountKey, provider

  balance: =>
    @db.hvals @transactionsKey
      .then (vals) =>
        sum = 0
        sum += parseInt(val) for val in vals
        sum

  # A transaction has a positive or negative value and is
  # related to a redis key
  transaction: (key, value, data) =>
    @db.hsetnx @transactionsKey, key, value
      .then parseInt
      .then (exists) =>
        throw "Existing transaction" if exists
      .then =>
        data or @db.get key
      .then (data) =>
        @emit 'transactions', data

