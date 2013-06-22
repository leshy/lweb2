Backbone = require 'backbone4000'
io = require 'socket.io-browserify'
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'

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

ChannelClient = Backbone.Model.extend4000
    initialize: ->
        @channels = {}
        
    channel: (channelname) ->
        if channel = @channels[channelname] then return channel
        channel = @channels[channelname] = new Channel lweb: @, name: channelname
        channel.on 'del', => delete @channels[channelname]
        return channel

    channelsubscribe: (channelname, pattern, callback) ->
        channel = @channel(channelname)
        if not callback and pattern.constructor is Function then callback = pattern; pattern = true
        channel.subscribe pattern, callback
        
lweb = exports.lweb = ChannelClient.extend4000 shared.queryClient, shared.queryServer,
    initialize: ->
        window.lweb = @
        @socket = io.connect @get('host') or "http://" + window.location.host
        @socket.on 'query', (msg) => @queryReceive msg, @socket
        @socket.on 'reply', (msg) => @queryReplyReceive msg, @socket
                        

