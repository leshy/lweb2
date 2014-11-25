Backbone = require 'backbone4000'
_ = require 'underscore'
helpers = require 'helpers'

SubscriptionMan = exports.SubscriptionMan = require('subscriptionman2')
validator = require('validator2-extras'); v = validator.v

channelInterface = exports.channelInterface = validator.validatedModel.extend4000
    validator: parent: 'Instance'
    
    initialize: ->
        @channels = {}

    channel: (channelname) ->
        if channel = @channels[channelname] then return channel
        channel = @channels[channelname] = new @ChannelClass parent: @, name: channelname
        channel.once 'del', => delete @channels[channelname]
        return channel

    channelsubscribe: (channelname, pattern, callback) ->
        channel = @channel(channelname)
        if not callback and pattern.constructor is Function then callback = pattern; pattern = true
        channel.subscribe pattern, callback

    broadcast: (channel,message) -> true
    join: (channel,listener) -> true
    part: (channel,listener) -> true
    del: -> true      

queryClient = exports.queryClient = validator.validatedModel.extend4000
    validator: parent: 'Instance'

    initialize: ->
        @callbacks = {}
        @parent.subscribe { type: 'reply', id: String }, (msg) => @queries[msg.id]?(msg.payload,msg.end)
            
    query: (payload,callback) ->
        if not payload then return console.warn 'tried to send a message without payload'
        @parent.send type: 'query', id: id = helpers.uuid(10), payload: payload
        @callbacks[id] = callback


Response = Backbone.Model.extend4000
    constructor: (@id, @send, @parent) ->
        @verbose = @parent.verbose
        @parent.responses[@id] = @
        Backbone.Model.apply @
        
    write: (payload) ->
        if @ended then console.warn 'writing to ended query',payload; return
        if not payload then throw 'no payload'
        if @verbose then console.log "<",@id,payload
        @send { type: 'reply', id: @id, payload: payload }

    end: (payload) ->
        if @ended then console.warn 'ending ended query',payload; return
        if @verbose then console.log "<<",@id, payload
        @ended = true        
        msg = { type: 'replyEnd', id: @id }
        if payload msg.payload = payload
        @send msg
        delete @parent.responses[@id]
        @trigger 'end'

    cancel: -> 
        @trigger 'cancel'; @end()

# as parent it expects something with send and receive methods that's a subclass of subscriptionman
queryServer = exports.queryServer = validator.validatedModel.extend4000, SubscriptionMan,
    validator: parent: 'Instance'
        
    initialize: ->
        @parent = @get 'parent'
        @verbose = @get 'verbose' or @parent.verbose
        
        @responses = {}
        
        parent.subscribe { type: 'query', id: String, payload: true }, (msg) =>
            if @verbose then console.log '>',msg.id,msg.payload
            @event msg.payload, new Response(msg.id, _.bind(parent.send, parent), @), realm            
            if not matches then delete @responses[msg.id]

        parent.subscribe { type: 'queryCancel', id: String }, (msg) =>
            if @verbose then console.log 'X',msg.id
            @responses[msg.id]?.cancel()
        
    subscribe: (pattern, callback) ->
        if not callback and pattern.constructor is Function then callback = pattern and pattern = true
        @subscribe pattern, callback

