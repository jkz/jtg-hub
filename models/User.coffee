{models} = require 'feeds'
events = require 'events'

db = require '../db'

class User extends events.EventEmitter
  @emitter: new events.EventEmitter

  @cache: {}

  @create: (id, options) =>
    return @cache[id] if @cache[id]
    @cache[id] = new this(id, options)
    @emitter.emit 'new', @cache[id]

  prefix: "/users"

  constructor: (@id, options={}) ->
    for key, val of options
      this[key] = val

    @db ?= db
    @key ?= "#{@prefix ? ''}/#{@id}"
    @transactionsKey ?= @key + '/transactions'
    @accountsKey ?= @key + '/accounts'

  accounts: =>
    @db.hgetall(@accountKey).then (accounts) ->
      require('./Account').create provider, id for provider, id of accounts

  account: (provider) =>
    @db.hget(provider).then (id) ->
      throw "No linked #{provider} account" unless id
      require('./Account').create provider, id

  link: (provider, id) =>
    require('./Account').create(provider, id).link(@id)

  unlink: (provider) =>
    @account(provider).then (account) ->
      account.unlink()

  balance: =>
    @db.hvals @transactionsKey
      .then (vals) =>
        sum = 0
        sum += parseInt(val) for val in vals
        sum

  # A transaction has a positive or negative value and is
  # related to a reference (redis key)
  transaction: ({ref, value, data}) =>
    @db.hsetnx @transactionsKey, ref, value
      .then parseInt
      .then (isNew) =>
        throw "Existing transaction" unless isNew
      .then =>
        data or @db.get ref
      # all([
      #   @db.get ref
      #   @balance
      # ]).then (data, balance)
      .then (data) =>
        @emit 'data',
          type: 'transaction'
          data: {ref, value, data}

module.exports = User
