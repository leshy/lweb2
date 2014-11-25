io = require 'socket.io'
Backbone = require 'backbone4000'
helpers = require 'helpers'
_ = require 'underscore'
SubscriptionMan = require('subscriptionman2')
# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'

Channel = SubscriptionMan.fancy.extend4000
    initialize: () ->
        @name = @get 'name' or throw 'channel needs a name'
        @clients = {}

    join: (reply,realm) ->
        console.log 'join to', @name, client.id
        @clients[reply.id].push = reply
        reply.on 'cancel' =>
            @part(reply)
        
    part: (reply) ->
        console.log 'part from', @name, reply.id
        reply.end()
        delete @clients[reply.id]
        if _.isEmpty @clients then @del() # garbage collect the channel
    
    broadcast: (msg) ->
        @event msg
        _.map @clients, (reply) => if reply.write msg
        
    del: ->
        @clients = {}
        @trigger 'del'


# this is the pub/sub core. it should be easy to extend to use zeromq or redis or something if I require horizontal scalability.
ChannelServer = shared.channelInterface.extend4000
    ChannelClass: Channel
    
    initialize: ->
        @channels = {}
        
    broadcast: (channelname,msg) ->
        console.log 'broadcast',channelname,msg
        if not channel = @channels[channelname] then return
        channel.broadcast msg

    join: (channelname,client) ->
        @channel(channelname).join client

    part: (channelname,socket) ->
        if not channel = @channels[channelname] then return
        channel.part socket


lweb = exports.lweb = shared.SubscriptionMan.extend4000 shared.queryClient, shared.queryServer, ChannelServer,
    initialize: -> 
        http = @get 'http'        
        if not http then throw "I need http instance in order to listen"
            
        @server = io.listen http, log: false # turning off socket.io logging

        # this kinda sucks, I'd like to hook messages on the server object level,
        # not create 4 new callbacks per client.. investigate.
        @server.on 'connection', (client) => 
            id = client.id
            host = client.handshake.address.address
            
#            console.log 'got connection from', host, id

            realm = {}
            realm.client = client
            
            # channels
            #client.on 'join', (msg) => @join msg.channel, client
            #client.on 'part', (msg) => @part msg.channel, client
            # queries
            client.on 'query', (msg) => @queryReceive msg, client, realm
            client.on 'reply', (msg) => @queryReplyReceive msg, client, realm

        @subscribe { join: String }, (msg, reply, realm) =>
            reply.write { joined: msg.join }
            @channel(msg.join).join reply, realm
                        
        # just a test channel broadcasts
        ###
        testyloopy = =>
            @broadcast 'testchannel', ping: helpers.uuid()
            helpers.sleep 10000, testyloopy
        testyloopy()
        ###

