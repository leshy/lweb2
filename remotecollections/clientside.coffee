


# has the same interface as local collections but it transparently talks to the remote collectionExposer via the messaging system,
RemoteCollection = exports.RemoteCollection = Backbone.Model.extend4000 ModelMixin, ReferenceMixin, SubscriptionMixin, Validator.ValidatedModel, MsgNode,
    validator: v(name: "String")
            
    create: (entry,callback) -> core.msgCallback @send( collection: @get('name'), create: entry ), callback
    
    remove: (pattern,callback) -> core.msgCallback @send( collection: @get('name'), remove: pattern, raw: true ), callback
    
    update: (pattern,data,callback) -> core.msgCallback @send( collection: @get('name'), update: pattern, data: data, raw: true ), callback
    
    find: (pattern,limits,callback) ->
        reply = @send( collection: @get('name'), find: pattern, limits: limits )
        reply.read (msg) -> if msg then callback(msg.data) else callback()

    findOne: (pattern,callback) ->
        reply = @send( collection: @get('name'), findOne: pattern )
        reply.read (msg) -> if msg then callback(undefined,msg.data) else callback("not found")

    fcall: (name, args, pattern, callback) ->
        reply = @send( collection: @get('name'), call: name, args: args, data: pattern )
        reply.read (msg) -> if msg then helpers.cbc callback, msg.err, msg.data;

