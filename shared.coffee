Backbone = require 'backbone4000'
_ = require 'underscore'
helpers = require 'helpers'

SubscriptionMan2 = exports.SubscriptionMan2 = require('./subscriptionman2').SubscriptionMan2

channelInterface = exports.channelInterface = Backbone.Model.extend4000
    initialize: ->
        @channels = {}

    channel: (channelname) ->
        if channel = @channels[channelname] then return channel
        channel = @channels[channelname] = new @ChannelClass lweb: @, name: channelname
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
    

class Response
    constructor: (@id, @client) -> 

    makereply: (payload,end) ->
        if @ended then throw 'reply already ended'
        msg = {}
        msg.id = @id
        if payload then msg.payload = payload
        if end then msg.end = true
        msg
        
    write: (payload) ->
        @client.emit 'reply', reply = @makereply(payload)
        
    end: (payload) ->
        @client.emit 'reply', reply = @makereply(payload, true)
        @ended = true

queryClient = exports.queryClient = Backbone.Model.extend4000
    initialize: ->
        @queries = []

    queryReplyReceive: (msg) ->
        console.log 'reply', msg.id, msg.payload
        if not callback = @queries[msg.id] then return
        if not msg.end
            callback msg.payload, false
        else
            callback msg.payload, true
            delete @queries[msg.id]
        
    query: (msg,callback) ->
        id = helpers.uuid(10)
        @queries[id] = callback
        console.log 'query',id,msg
        @socket.emit 'query', { id: id, payload: msg }
        true

queryServer = exports.queryServer = SubscriptionMan2.extend4000
    queryReceive: (msg,client,realm) ->
        console.log 'got query',msg
        if not msg.payload or not msg.id then return console.warn 'invalid query message received:',msg
        @event msg.payload, msg.id, client, realm
    
    subscribe: ( pattern, callback ) ->
        if not callback and pattern.constructor is Function then callback = pattern and pattern = true
        wrapped = (msg, id, client, realm) -> callback msg, new Response(id,client), realm
        SubscriptionMan2::subscribe.call this, pattern, wrapped        

