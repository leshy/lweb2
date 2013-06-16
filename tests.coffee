lwebs = require './serverside'
lwebc = require './clientisde'

# this is just a sketch..
# the idea is to keep things fast and simple,
# channel broadcasts and easy and simmetric JSON query/response system, supporting multiple messages in a response.

exports.basic = (test) ->
    lwebs = lwebs.listen()
    lwebc = lwebc.connect()

    lwebc.channels.on 'channel1', (msg) -> console.log 'channel msg',msg
            

    lwebs.channels.broadcast 'channel1', { message: 'test message1' }

    lwebs.on { bla: true }, (msg,response,client) ->
        response.send response: 1
        response.end response: 2

    # callback will be called three times, two times for each of the messages received, and third time, with no arguments, marking the ending of a query reply        
    lwebc.query bla: 3, (err,msg) -> console.log 'got', msg

    # or?
    # not sure, lets leave streaming for later..
    lwebc.query(bla: 3).stream().on { response: true}, (err,data) ->
        true
    
    # please check login conversation implementation on top of comm5, to see what kind of API would be nice



