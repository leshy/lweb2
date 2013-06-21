Backbone = require 'backbone4000'
_ = require 'underscore'

SimpleMatcher = Backbone.Model.extend4000
    match: (value,pattern) ->
        if pattern is true then return true
            
        not _.find pattern, (checkvalue,key) ->
            if not value[key] then return true
            if checkvalue isnt true and value[key] isnt checkvalue then return true
            false

SubscriptionMan = exports.SubscriptionMan = SimpleMatcher.extend4000
    initialize: -> @subscriptions = []

    subscribe: (pattern,callback,name) -> @subscriptions.push pattern: pattern, callback: callback
    
    event: (value) ->
        subscriptions = _.filter @subscriptions, (subscription) => @match value, subscription.pattern
        _.map subscriptions, (subscription) ->
            subscription.callback(value)

channelInterface = exports.channelInterface = SubscriptionMan.extend4000
    broadcast: (channel,message) -> true
    subscribe: (channel,listener) -> true
    unsubscribe: (channel,listener) -> true
    del: -> true

lwebInterface = exports.lwebInterface = Backbone.Model.extend4000
    initialize: -> true
    query: (msg) -> true

