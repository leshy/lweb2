lwebs = require './serverside'
lwebc = require './clientside'
shared = require './shared'

# this is just a sketch..
# the idea is to keep things fast and simple,
# channel broadcasts and easy and simmetric JSON query/response system, supporting multiple messages in a response.

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
