{Adapter, TextMessage, User} = require "hubot"
tgapi = require '../telegram-cli-wrapper'

extend = (dst, src) ->
  Object.keys(src).forEach (key) ->
    dst[key] = src[key]
  dst

class TelegramAdapter extends Adapter
  constructor: (@robot) ->
    unless process.env.TELEGRAM_PHONE_NUMBER
      throw Error 'Configuration TELEGRAM_PHONE_NUMBER is required'

    setInterval =>
      @connection?.executeCommand('main_session', log: false)
    , 1000

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
      if @connection.contacts
        @_startWorking()
      else
        @connection.once 'contacts', @_startWorking

  _startWorking: =>
    @emit 'connected'
    @connection.contacts.map (contact) =>
      @robot.brain.userForId contact.id, extend(name: contact.print_name, contact)
    @connection.on 'message', @_onReceiveMessage

  _onReceiveMessage: (message) =>
    {from, to} = message
    return if from.phone is @phoneNumber
    room = if to.type is 'chat' then to.print_name else null
    user = new User from.id, extend(name: from.print_name, room: room, from)
    message = new TextMessage user, message.text, message.id
    @connection.markAllReaded user.name
    @robot.receive message, =>
      @connection.stopTyping user.name

exports.use = (robot) ->
  new TelegramAdapter robot
