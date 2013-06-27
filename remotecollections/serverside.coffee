Backbone = require 'backbone4000'
_ = require 'underscore'
helpers = require 'helpers'
Validator = require 'validator2-extras'; v = Validator.v; Select = Validator.Select

SubscriptionMan2 = require('./../subscriptionman2').SubscriptionMan2

collections = require 'collections'
mongo = require 'collections/serverside/mongodb'
shared = require '../shared'
callbackMsgEnd = (reply) -> (err,data) -> reply.end err: err, data: data
 
# a mixin that exposes a collection with a standard interface to lweb messaging layer
CollectionExposer = exports.CollectionExposer = Backbone.Model.extend4000
    defaults: { name: undefined }
    initialize: ->
        name = @get 'name'
        lweb = @get 'lweb'
        
        # create
        lweb.subscribe { collection: name, create: true },
            (msg,reply) => @create msg.create, callbackMsgEnd reply
        
        # remove raw
        lweb.subscribe { collection: name, remove: true, raw: true  },
            (msg,reply) => @remove msg.remove, callbackMsgEnd reply
        
        # update raw
        lweb.subscribe { collection: name, update: true, data: true, raw: true },
            (msg,reply) => @update msg.update, msg.data, callbackMsgEnd reply
            
        # remove
        lweb.subscribe { collection: name, remove: true },
            (msg,reply) => @findModels msg.remove, {}, (entry) -> 
                if entry? then entry.remove() else reply.end()

        # update
        lweb.subscribe { collection: name, update: true, data: true },
            (msg,reply) => @findModels msg.update, {}, (entry) =>
                if entry? then entry.update(data,'public'); entry.flush() else reply.end()
        
        # find
        lweb.subscribe { collection: name, find: true },
            (msg,reply) => @find msg.find, msg.limits or {}, (entry) =>
                if entry? then reply.write ({ data: entry, err: undefined }) else reply.end()

        # findOne
        lweb.subscribe { collection: name, findOne: true },
            (msg,reply) =>
                @findOne msg.findOne, (err, entry) =>
                if entry? then reply.write ({ data: entry, err: undefined }) else reply.end()
                
        # call
        lweb.subscribe { collection: name, call: true, data: true },
            (msg,reply,realm) => @fcall msg.call, msg.args or [], msg.data, realm, (err,data) ->
                reply.end { err: err, data: data }
        

    subscribeModel: (id,callback) ->
        true


# this can be mixed into a RemoteCollection or Collection itself.
# it provides subscribe and unsubscribe methods for collection events (remove/update/create)
# 
# if this is mixed into a collection,
# remotemodels will automatically subscribe to those events to update themselves with potential remote changes
SubscriptionMixin = exports.SubscriptionMixin = shared.SubscriptionMan2.extend4000
    superValidator: v({ create: 'function', update: 'function', remove: 'function' })

    create: (entry,callback) ->
        @_super 'create', entry, (err,id) =>
            @event action: 'create', entry: _.extend({id : id}, entry)
            callback(err,id)
        
    update: (pattern,update,callback) ->
        @_super 'update', pattern, update, callback
        if pattern.id then @event action: 'update', id: pattern.id, update: update
        
    remove: (pattern,callback) ->
        @_super 'remove', pattern, callback
        if pattern.id then @event action: 'remove', id: pattern.id

    subscribeModel: (id,callback) ->
        @subscribe { pattern: { id: id } }, (msg) -> callback(msg)
        
    unsubscribeModel: ->
        true

exports.MongoCollection = mongo.MongoCollection.extend4000 CollectionExposer, collections.ReferenceMixin, collections.ModelMixin, exports.SubscriptionMixin




