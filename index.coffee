backbone = require 'backbone4000'
subscriptionMan2 = require 'subscriptionman2'


# query reply system on top of streaming protocol


streamingProtocol = backbone.Model.extend4000
    send: (data) -> true
    receive: (callback) -> callback('msg','realm')

conversationMan = subscriptionMan2.extend4000 
    query: (msg) ->
        