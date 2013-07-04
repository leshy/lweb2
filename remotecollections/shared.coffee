Backbone = require 'backbone4000'
Validator = require 'validator2-extras'; v = Validator.v; Select = Validator.Select

# this can be mixed into a RemoteCollection or Collection itself.
# it provides subscribe and unsubscribe methods for collection events (remove/update/create)
# 
# if this is mixed into a collection,
# remotemodels will automatically subscribe to those events to update themselves with potential remote changes

SubscriptionMixin = exports.SubscriptionMixin = Validator.ValidatedModel.extend4000
    superValidator: v({ create: 'function', update: 'function', remove: 'function' })
    validator: v(lweb: "Instance")

    initialize: ->
        @lweb = @get 'lweb'

    create: (entry,callback) ->
        @_super 'create', entry, (err,id) =>
            #@event action: 'create', entry: _.extend({id : id}, entry)
            #callback(err,id)
        
    update: (pattern,update,callback) ->
        @_super 'update', pattern, update, callback
        if pattern.id then @lweb.broadcast pattern.id, { action: 'update', update: update }
        
    remove: (pattern,callback) ->
        @_super 'remove', pattern, callback
        if pattern.id then @lweb.broadcast pattern.id { action: 'remove', id: pattern.id }


    subscribeModel: (id,callback) ->
        @get('lweb').channel(id).subscribe true, (msg) -> callback(msg)
       
    unsubscribeModel: -> true
