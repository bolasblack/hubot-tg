{Adapter, TextMessage, User} = require "hubot"
tglink = require('telegram.link')()
Promise = require 'bluebird'
os = require 'os'

class TelegramAdapter extends Adapter
  constructor: (@robot) ->
    unless process.env.TELEGRAM_PHONE_NUMBER
      throw Error 'Configuration TELEGRAM_PHONE_NUMBER is required'

    @phoneNumber = process.env.TELEGRAM_PHONE_NUMBER
    @redisKeyPrefix = 'tg:' + @phoneNumber
    @connectPromise = @__createClient().then(@__createAuthKey).then(@__sendCode).then(@__signIn)
      .then (client) => @emit 'connected'
      .catch (err) ->
        if err instanceof Error
          console.error err
        else
          console.log err
        Promise.reject err

    super

  send: (envelope, strings...) ->

  reply: (envelope, strings...) ->

  run: ->

  __createClient: ->
    new Promise (resolve, reject) =>
      @client = tglink.createClient {
        id: 45444
        hash: 77946f08ac75f235a8357521d2ee31a6
        version: require('../package.json').version
        lang: 'en'
        deviceModel: os.type().replace('Darwin', 'OS_X')
        systemVersion: os.platform() + '/' + os.release()
      }, telegramLink.PROD_PRIMARY_DC, (err) =>
        if err
          reject err
          console.error 'Connect to Telegram failed', err
        else
          resolve @client
          @emit 'tg:connected'

  __createAuthKey: (client) ->
    new Promise (resolve, reject) =>
      if @robot.brain.get redisKeyPrefix + 'authKey'
        resovle(client)
      else
        client.createAuthKey (err, authKey) =>
          return reject(err) if err
          @robot.brain.set redisKeyPrefix + 'authKey', authKey
          resolve client

  __signIn: (client) ->
    new Promise (resolve, reject) =>
      phoneCodeHash = @robot.brain.get redisKeyPrefix + 'phone_code_hash'
      smsCode = process.env.TELEGRAM_SMS_CODE
      if not smsCode
        reject 'Waiting for sms code...'
      else
        client.auth.signIn @phoneNumber, phoneCodeHash, smsCode, (err, data) =>
          @robot.brain.set redisKeyPrefix + 'robotInfo', data
          resolve client

  __sendCode: (client) ->
    new Promise (resolve, reject) =>
      if @robot.brain.get redisKeyPrefix + 'phone_code_hash'
        resolve client
      else
        client.auth.sendCode @phoneNumber, 0, 'en', (err, data) =>
          return reject(err) if err
          @robot.brain.set redisKeyPrefix + 'phone_code_hash', data.phone_code_hash
          resolve client

exports.use = (robot) ->
  new TelegramAdapter robot
