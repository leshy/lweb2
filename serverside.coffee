io = require 'socket.io'
Backbone = require 'backbone4000'
helpers = require 'helpers'
_ = require 'underscore'

# inherit code common to serverside and clientside
_.extend exports, shared = require './shared'

Channel = shared.SubscriptionMan2.extend4000
    initialize: () ->
        @name = @get 'name' or throw 'channel needs a name'
        @clients = {}

    join: (client) ->
        @clients[client.id] = client
        client.on 'disconnect', => @part client
        
    part: (client) ->
        console.log 'part from', @name, client.id
        delete @clients[client.id]
        if _.isEmpty @clients then @del() # garbage collect the channel
    
    broadcast: (msg, exclude) ->
        _.map @clients, (subscriber) => if subscriber isnt exclude then subscriber.emit(@name, msg)
        
    del: ->
        @clients = {}
        @trigger 'del'

# this is the core.. it should be easy to extend to use zeromq or redis or something if I require horizontal scalability.. db is a bottleneck then, but I can distribute that too
ChannelServer = shared.channelInterface.extend4000
    initialize: ->
        @channels = {}
        
    broadcast: (channelname,msg) ->
        console.log 'broadcast',channelname,msg
        if not channel = @channels[channelname] then return
        channel.broadcast msg

    join: (channelname,client) ->
        console.log 'join to', channelname
        if not channel = @channels[channelname]
            channel = @channels[channelname] = new Channel name: channelname
            channel.on 'del', => delete @channels[channelname]
        channel.join client

    part: (channelname,socket) ->
        if not channel = @channels[channelname] then return
        channel.part socket

lweb = exports.lweb = shared.SubscriptionMan2.extend4000 shared.queryClient, shared.queryServer, ChannelServer,
    listen: (http = @get 'http', options = @get 'options') ->
        @server = io.listen(http, options or {})

        @server.on 'connection', (client) =>
            id = client.id
            host = client.handshake.address.address
            
            console.log 'got connection from', host, id
            client.on 'join', (msg) => @join msg.channel, client
            client.on 'part', (msg) => @part msg.channel, client

            client.on 'query', (msg) =>
                console.log 'received query',msg
                @queryReceive msg, client
            client.on 'reply', (msg) => @queryReplyReceive msg, client

        loopy = =>
            @broadcast 'testchannel', ping: helpers.uuid()
            helpers.sleep 5000, loopy
            
        loopy()


