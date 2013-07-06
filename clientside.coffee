Validator = require 'validator2-extras'; v = Validator.v; Select = Validator.Select
Backbone = require 'backbone4000'
io = require 'socket.io-browserify'
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'
_.extend exports, collections = require './remotecollections/clientside.coffee'

Channel = exports.Channel = shared.SubscriptionMan2.extend4000
    validator: v(name: "String", lweb: "Instance")

    initialize: ->
        @name = @get 'name' or throw 'channel needs a name'
        @socket = @get('lweb').socket or throw 'channel needs lweb'

        @socket.on @name, (msg) => @event msg
        
        @on 'unsubscribe', => if not _.keys(@subscriptions).length then @part()
        @on 'subscribe', -> if not @joined then @join()

    join: ->
        if @joined then return
        console.log 'join to', @name
        @socket.emit 'join', { channel: @name }        
        @joined = true
        
    part: ->
        if not @joined then return
        console.log 'part from', @name
        @socket.emit 'part', { channel: @name }
        @joined = false
        
    del: ->
        @part()
        @trigger 'del'

ChannelClient = shared.channelInterface.extend4000
    ChannelClass: Channel

lweb = exports.lweb = ChannelClient.extend4000 shared.queryClient, shared.queryServer,
    initialize: ->
        window.lweb = @
        @socket = io.connect @get('host') or "http://" + window.location.host
        @socket.on 'query', (msg) => @queryReceive msg, @socket
        @socket.on 'reply', (msg) => @queryReplyReceive msg, @socket
                        
    collection: (name) -> new exports.RemoteCollection lweb: @, name: name

