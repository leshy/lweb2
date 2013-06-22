lweb
====

simple horizontally scalable websocket comm framework supporting channels and queries

serverside
----------
```coffeescript
lweb = new lweb.lweb http: env.http
lweb.listen()

# single message reply
lweb.subscribe ping: true, (msg,reply) -> reply.end pong: msg.ping + 1

# multi message reply
lweb.subscribe testattr: 'hi', stream: true, (msg,reply) ->
    _.count msg.stream, -> reply.write test: new Date.getTime()
    reply.end test: 'done'


# channel broadcast
lweb.broadcast 'testchannel', bla: 3
````

clientside
----------
```coffeescript
lweb = new lweb()

lweb.query { ping: 3 }, (msg) ->
    console.log msg.pong

lweb.subscribe 'testchannel', (msg) ->
    console.log msg


lweb.subscribe 'testchannel', some: 'pattern', (msg) ->
    console.log msg


testchannel = lweb.channel 'testchannel'

testchannel.subscribe some: 'other', pattern: true, (msg) ->
    console.log msg
```
