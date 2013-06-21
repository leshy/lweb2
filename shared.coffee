Backbone = require 'backbone4000'

channelInterface = exports.channelInterface = Backbone.Model.extend4000
    broadcast: (channel,message) -> true
    subscribe: (channel,listener) -> true
    unsubscribe: (channel,listener) -> true
    del: -> true

lwebInterface = exports.lwebInterface = Backbone.Model.extend4000
    initialize: -> true
    query: (msg) -> true

SimpleMatcher = Backbone.Model.extend4000
    match: (value,pattern) ->
        if pattern == true then return true
        true        

SubscriptionMan = exports.SimpleSubscriptionMan = SimpleMatcher.extend4000
    initialize: ->
        cnt = 0
        @subscriptions = {}

    subscribe: (pattern,callback,name) -> @subscriptions.push pattern: pattern, callback: callback
    
    event: (value) ->
        subscriptions = _.filter @subscriptions, (subscription) => @match value, subscription.pattern
        _.map subscriptions, (subscription) ->
            subscription.callback(value)

