
basic = (test) ->
    x = new conversationMan()

    query = x.query(bla: true).reply (msg,reply) ->
        reply.end