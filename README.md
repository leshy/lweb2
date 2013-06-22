lweb
====

simple horizontally scalable websocket comm framework supporting channels and queries
messages are JSON objects

clientside
----------
```coffeescript
# the idea for this is to be browserified (https://github.com/substack/node-browserify)
lweb = new require('lweb/clientside').lweb()

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


serverside
----------
```coffeescript
lweb = new require('lweb/serverside').lweb http: env.http

# single message reply
# matches messages containing the attribute 'ping' (expecting number)

lweb.subscribe ping: true, (msg,reply) -> reply.end pong: msg.ping + 1

# multi message reply
# matches messages containing the attribute testattr which is equal to 'hi' and attribute stream which can be anything (expecting number)
lweb.subscribe testattr: 'hi', stream: true, (msg,reply) ->
    _.count msg.stream, -> reply.write test: new Date.getTime()
    reply.end test: 'done'

# channel broadcast
lweb.broadcast 'testchannel', bla: 3
````
