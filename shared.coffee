Backbone = require 'backbone4000'
_ = require 'underscore'
helpers = require 'helpers'

SubscriptionMan2 = require('./subscriptionman2').SubscriptionMan2

channelInterface = exports.channelInterface = Backbone.Model.extend4000
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
        @client.emit 'reply', @makereply(payload)
        
    end: (payload) ->
        @client.emit 'reply', @makereply(payload, true)
        @ended = true

queryClient = exports.queryClient = Backbone.Model.extend4000
    initialize: ->
        @queries = []

    queryReplyReceive: (msg) ->
        callback = @queries[msg.id]        
        if not msg.end
            callback msg.payload, false
        else
            callback msg.payload, true
            delete @queries[msg.id]
        
    query: (msg,callback) ->
        id = helpers.uuid(10)
        @queries[id] = callback
        @socket.emit 'query', { id: id, payload: msg }
        true

queryServer = exports.queryServer = SubscriptionMan2.extend4000
    queryReceive: (msg,client) ->
        if not msg.payload or not msg.id then return console.warn 'invalid query message received:',msg
        @event msg.payload, msg.id, client
                        
    subscribe: ( pattern, callback ) ->
        if not callback and pattern.constructor is Function then callback = pattern and pattern = true
        wrapped = (msg, id, client) -> callback msg, new Response(id,client)                
        SubscriptionMan2::subscribe.call this, pattern, wrapped        

