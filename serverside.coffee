io = require 'socket.io'
Backbone = require 'backbone4000'
SubscriptionMan = require('subscriptionman').SubscriptionMan
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'

Channel = shared.channelInterface.extend4000 # subscriberman in the future..
    initialize: () ->
        @name = @get 'name' or throw 'channel needs a name'
        @subscribers = {}

    subscribe: (client) ->
        @subscribers[client.id] = client
        client.on 'disconnect', => @unsubscribe client
        
    unsubscribe: (client) ->
        delete @subscribers[client.id]
                
    broadcast: (msg, exclude) ->
        _.map @subscribers, (subscriber) => subscriber.emit(@name, msg) if not subscriber is exclude else undefined

    del: ->
        @subscribers = {}

# this is the core.. it should be easy to extend to use zeromq or redis or something if I require horizontal scalability.. db is a bottleneck then, but I can distribute that too
ChannelServer = shared.channelInterface.extend4000
    initialize: ->
        @channels = {}
        
    broadcast: (channelname,msg) ->
        console.log 'broadcast',channelname,msg
        if not channel = @channels[channelname] then return
        channel.broadcast msg

    subscribe: (channelname,client) ->
        console.log 'subscribe to', channelname
        if not channel = @channels[channelname] then channel = @channels[channelname] = new Channel name: channelname
        channel.subscribe client

    unsubscribe: (channel,socket) ->
        if not channel = @channels[channel] then return
        channel.unsubscribe socket

exports.lweb = shared.lwebInterface.extend4000 ChannelServer,
    listen: (http = @get 'http', options = @get 'options') ->
        @server = io.listen(http, options or {})

        @server.on 'connection', (client) =>
            # channel msg
            # client.on 'cmsg', (msg) => @broadcast msg.c, msg.m
            # channel sub/unsub
            id = client.id
            host = client.handshake.address.address
            
            console.log 'got connection from', host, id
            client.on 'subscribe', (msg) =>
                @subscribe msg.channel, client
            client.on 'unsubscribe', (msg) => @unsubscribe msg.channel, client
            
            client.on 'disconnect', => _.map client.channels, (channel) => @unsubscribe channel, client

        loopy = =>
            @broadcast 'testchannel', ping: new Date().getTime()
            helpers.sleep 1000, loopy
            
        loopy()