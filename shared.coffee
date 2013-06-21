Backbone = require 'backbone4000'
_ = require 'underscore'
helpers = require 'helpers'

SimpleMatcher = Backbone.Model.extend4000
    match: (value,pattern) ->
        if pattern is true then return true
            
        not _.find pattern, (checkvalue,key) ->
            if not value[key] then return true
            if checkvalue isnt true and value[key] isnt checkvalue then return true
            false

SubscriptionMan2 = exports.SubscriptionMan2 = SimpleMatcher.extend4000
    initialize: -> @subscriptions = []

    subscribe: (pattern,callback,name) ->
        if not callback and pattern.constructor is Function
            callback = pattern
            pattern = true
        @subscriptions.push pattern: pattern, callback: callback
    
    event: (values...) ->
        value = _.first values
        subscriptions = _.filter @subscriptions, (subscription) => @match value, subscription.pattern
        _.map subscriptions, (subscription) ->
            subscription.callback.apply @, values

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
        callback(msg.payload)
        if msg.end then delete @queries[msg.id]
            
    query: (msg,callback) ->
        id = helpers.uuid(10)
        @queries[id] = callback
        @socket.emit 'query', { id: id, payload: msg }

queryServer = exports.queryServer = SubscriptionMan2.extend4000

    queryReceive: (msg,client) ->
        if not msg.payload or not msg.id then return console.warn 'invalid query message received:',msg
        @event msg.payload, msg.id, client
                        
    subscribe: ( pattern, callback ) ->
        if not callback and pattern.constructor is Function then callback = pattern and pattern = true
        wrapped = (msg, id, client) -> callback msg, new Response(id,client)                
        SubscriptionMan2::subscribe.call this, pattern, wrapped        


