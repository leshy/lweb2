io = require 'socket.io'
Backbone = require 'backbone4000'
SubscriptionMan = require('subscriptionman').SubscriptionMan
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, require './shared'


# this is the core.. it should be easy to extend to use zeromq or redis or something if I require horizontal scalability.. db is a bottleneck then, but I can distribute that too
ChannelServer = Backbone.Model.extend4000
    initialize: ->
        @channels = {}
        
    broadcast: (channel,message) ->
        if not channel = @channels[channel] then return
        _.map channel, (listener) -> listener(message)

    subscribe: (channel,listener) ->
        if not channel = @channels[channel] then @channels[channel] = []
        @channels[channel].push listener        
        return => @unsubscribe channel, listener

    unsubscribe: (channel,listener) ->
        if not channel = @channels[channel] then return
        helpers.remove @channels[channel], listener

WebsocketServer = exports.WebsocketServer = Backbone.Model.extend4000
    initialize: ->
        server = io.listen @get('http'), @get('options')
        server.on 'connection', (socket) ->
            
            console.log 'received connection'
            
            socket.once 'login', (msg) ->
                console.log 'login',msg
                socket.emit 'login', { user: { secret: 'somesecret', name: 'perica' } }

                socket.on 'msg', (msg) ->
                    console.log 'msg',JSON.stringify(msg)
                                        
            true

