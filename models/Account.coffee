{models} = require 'feeds'
events = require 'events'

db = require '../db'

class Account extends events.EventEmitter
  @cache: {}

  @create: (provider, id, options) =>
    (@cache[@provider] ?= {})[id] ?= new this provider, id, options

  prefix: '/accounts'

  constructor: (@provider, @id, options={}) ->
    this[key] = val for key, val of options

    @db ?= db
    @key ?= "#{@prefix}/#{@provider}/#{@id}"
    @detailsKey ?= @key + '/details'
    @transactionsKey ?= @key + '/transactions'

  user: =>
    @db.get(@key)
      .then (uid) ->
        throw "No linked user" unless uid
        require('./User').create uid

  link: (user_id) =>
    @db.multi()
    @db.set @key, user_id
    @db.hset require('./User').create(user_id).accountsKey, @provider, @id
    @db.exec()

  unlink: =>
    @db.multi()
    @db.del @key
    @db.hdel require('./User').create(user_id).accountsKey, @provider
    @db.exec()

  balance: =>
    @db.hvals @transactionsKey
      .then (vals) =>
        sum = 0
        sum += parseInt(val) for val in vals
        sum

  # A transaction has a positive or negative value and is
  # related to a redis key
  transaction: ({key, value, data, ref}) =>
    @db.hsetnx @transactionsKey, ref, value
      .then parseInt
      .then (exists) =>
        throw "Existing transaction" if exists
      .then =>
        data or @db.get ref
      .then (data) =>
        @emit 'transactions', data

  details: =>
    @db.hgetall @detailsKey

module.exports = Account


