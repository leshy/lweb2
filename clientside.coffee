Validator = require 'validator2-extras'; v = Validator.v; Select = Validator.Select
Backbone = require 'backbone4000'
io = require 'socket.io-browserify'
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'
_.extend exports, collections = require './remotecollections/clientside'

Channel = exports.Channel = shared.SubscriptionMan.extend4000
    validator: v(name: "String", parent: "Instance")
    
    initialize: ->
        @name = @get 'name'
        @parent = @get 'parent'

        @on 'unsubscribe', => if not _.keys(@subscriptions).length then @part()
        @on 'subscribe', -> if not @joined then @join()

    join: (callback) ->
        if @joined then return
        console.log 'join to', '#' + @name
        @parent.query join: @name, (msg) =>
            if not msg.err
                @joined = true
                @parent.subscribe channel: @name, (msg) => @event msg.msg
                callback()
            else
                callback msg.err
        
    part: ->
        if not @joined then return
        console.log 'part from', '#' + @name
        @socket.emit 'part', { channel: @name }
        @joined = false
        
    del: ->
        @part()
        @trigger 'del'

ChannelClient = shared.channelInterface.extend4000
    ChannelClass: Channel

lweb = exports.lweb = ChannelClient.extend4000 shared.queryClient, shared.queryServer,
    initialize: ->
        if window? then window?lweb = @
        @socket = io.connect @get('host') or "http://" + window?location?host
        @socket.on 'query', (msg) => @queryReceive msg, @socket
        @socket.on 'reply', (msg) => @queryReplyReceive msg, @socket
                        
    collection: (name) -> new exports.RemoteCollection lweb: @, name: name


