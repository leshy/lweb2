Backbone = require 'backbone4000'
io = require 'socket.io-browserify'
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'
_.extend exports, collections = require './remotecollections/clientside.coffee'

Channel = exports.Channel = shared.SubscriptionMan2.extend4000
    initialize: ->
        @name = @get 'name' or throw 'channel needs a name'
        @socket = @get('lweb').socket or throw 'channel needs lweb'
        @socket.emit 'join', { channel: @name }
        @socket.on @name, (msg) => @event msg

    part: ->
        @socket.emit 'part', { channel: @name }
        @trigger 'del'
        
    del: -> @part()

ChannelClient = shared.channelInterface.extend4000 {}

lweb = exports.lweb = ChannelClient.extend4000 shared.queryClient, shared.queryServer,
    initialize: ->
        window.lweb = @
        @socket = io.connect @get('host') or "http://" + window.location.host
        @socket.on 'query', (msg) => @queryReceive msg, @socket
        @socket.on 'reply', (msg) => @queryReplyReceive msg, @socket
                        
    collection: (name) -> new exports.RemoteCollection lweb: @, name: name

