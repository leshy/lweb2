Backbone = require 'backbone4000'
_ = require 'underscore'

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
