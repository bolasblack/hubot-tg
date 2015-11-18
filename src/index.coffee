{Adapter, TextMessage, User} = require "hubot"
tgapi = require 'telegram-cli-nodejs'

extend = (dst, src) ->
  Object.keys(src).forEach (key) ->
    dst[key] = src[key]
  dst

class TelegramAdapter extends Adapter
  constructor: (@robot) ->
    unless process.env.TELEGRAM_PHONE_NUMBER
      throw Error 'Configuration TELEGRAM_PHONE_NUMBER is required'

    @phoneNumber = process.env.TELEGRAM_PHONE_NUMBER
    @robot.on 'tg:typing', (envelope) =>
      return unless envelope?.user?.name?
      @connection.startTyping envelope.user.name
    super

  send: (envelope, strings...) ->
    strings.forEach (string) =>
      @connection.send envelope.room or envelope.user.name, string

  reply: (envelope, strings...) ->
    strings.forEach (string) =>
      @connection.reply envelope.message.id, string

  run: ->
    tgapi.connect (@connection) =>
      @emit 'connected'
      @connection.on 'message', @_onReceiveMessage

  _onReceiveMessage: (message) =>
    {from, to} = message
    return if from.phone is @phoneNumber
    room = if to.type is 'chat' then to.print_name else null
    user = new User from.id, extend(name: from.print_name, room: room, from)
    message = new TextMessage user, message.text, message.id
    @connection.markLastMessageReaded from.name
    @robot.receive message, =>
      @connection.stopTyping envelope.user.name

exports.use = (robot) ->
  new TelegramAdapter robot
