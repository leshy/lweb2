io = require 'socket.io-browserify'
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'

Channel = exports.Channel = shared.SubscriptionMan.extend4000
    initialize: ->
        @name = @get 'name' or throw 'channel needs a name'
        @socket = @get('lweb').socket or throw 'channel needs lweb'
        @socket.emit 'subscribe', { channel: @name }
        @socket.on @name, (msg) => @event msg

    unsubscribe: -> @socket.emit 'unsubscribe', { channel: @name }        

    del: -> @unsubscribe()

lweb = exports.lweb = shared.lwebInterface.extend4000
    connect: (host = "http://" + window.location.host) -> @socket = io.connect host
    once: (args...) -> @socket.once.apply @socket, args
    on: (args...) -> @socket.on.apply @socket, args
    emit: (args...) -> @socket.once.apply @socket, args
    subscribe: (channelname) -> return new Channel lweb: @, name: channelname
