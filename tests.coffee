Lwebs = require './serverside'
Lwebc = require './clientside'
shared = require './shared'
helpers = require 'helpers'
# this is just a sketch..
# the idea is to keep things fast and simple,
# channel broadcasts and easy and simmetric JSON query/response system, supporting multiple messages in a response.

express = require 'express'
Http = require 'http'

port = 8192

gimmeEnv = (callback) ->
    app = express()
    app.configure ->
        app.set 'view engine', 'ejs'
        app.use express.favicon()
        app.use express.bodyParser()
        app.use express.methodOverride()
        app.use express.cookieParser()
        app.use app.router
        app.use (err, req, res, next) ->
            res.send 500, 'BOOOM!'
            
    http = Http.createServer app
    
    # I dont know why but I need to cycle ports, maybe http doesn't fully close, I don't know man.
    http.listen ++port 

    lwebs = new Lwebs.lweb http: http
    lwebc = new Lwebc.lweb host: 'http://localhost:' + port
    
    lwebs.server.on 'connection', ->
        callback lwebs, lwebc, http, (test) ->
            lwebc.socket.disconnect()
            http.close -> test.done()


exports.connect = (test) ->
    gimmeEnv (lwebs,lwebc,http,done) ->
        done test

exports.query = (test) ->
    gimmeEnv (lwebs,lwebc,http,done) ->
        lwebs.subscribe bla: true, (query,realm,reply) ->
            test.deepEqual query, bla: 33
            done test
        lwebc.query bla: 33

exports.queryReply = (test) ->
    gimmeEnv (lwebs,lwebc,http,done) ->        
        lwebs.subscribe bla: true, (query,reply) ->
            test.deepEqual query, bla: 33
            reply.end { blu: 66 }
            
        lwebc.query bla: 33, (reply) ->
            test.deepEqual reply, blu: 66
            done test

exports.queryStreamReply = (test) ->
    gimmeEnv (lwebs,lwebc,http,done) ->
        
        lwebs.subscribe bla: true, (query,reply) ->
            test.deepEqual query, bla: 33
            helpers.wait 10, -> reply.write { r: 2 }
            helpers.wait 30, -> reply.write { r: 6 }
            helpers.wait 50, -> reply.write { r: 1 }
            helpers.wait 90, -> reply.end { r: 88 }
            
        total = 0
        lwebc.query bla: 33, (reply,end) ->
            total += reply.r
            if end
                test.deepEqual reply, r:88
                test.equal total, 97
                done test
                                    


exports.channels = (test) ->
    gimmeEnv (lwebs,lwebc,http,done) ->
        lwebc.channel('bla').join() # join should have a callback
        lwebc.channels.bla.subscribe bla: true, (msg) ->
            done test

        helpers.wait 50, -> 
            lwebs.channels.bla.broadcast bla: 3



exports.basic = (test) ->
    test.done() # this is just a sketch
    return
    
    lwebs = lwebs.listen()
    lwebc = lwebc.connect()

    lwebc.channels.on 'channel1', (msg) -> console.log 'channel msg',msg
    lwebs.channels.broadcast 'channel1', message: 'test message1'

    lwebs.subscribe { bla: true }, (msg,response,client) ->
        response.write { response: 1 }
        response.write { response: 2 }
        response.end { response: 3 }

    # callback will be called three times, two times for each of the messages received, and third time, with no arguments, marking the ending of a query reply        
    lwebc.query bla: 3, (err,msg) -> console.log 'got', msg

    # or?
    # not sure, lets leave streaming for later..
    lwebc.multiQuery bla: 3, (err,data) -> true
                
    # check login conversation implementation on top of comm5, to see what kind of API would be nice..
    # you were thinking about some kind of reply subclass that could have protocol implementation on top of itself. that sounds good.
    # lets leave this for laters... keep it as simple as possible.

exports.SimpleSubscriptionMan = (test) ->
    a = new shared.SubscriptionMan()
    a.subscribe { bla: true }, (msg) -> test.done()
    a.event { bla: 'test1' }

exports.SimpleSubscriptionMan_fail = (test) ->
    a = new shared.SubscriptionMan()
    a.subscribe { bla: 'testx' }, (msg) -> test.fail()
    a.event { bla: 'test1' }
    test.done()

exports.SimpleSubscriptionMan_exact = (test) ->
    a = new shared.SubscriptionMan()
    a.subscribe { bla: 'test1' }, (msg) -> test.done()
    a.event { bla: 'test1' }
