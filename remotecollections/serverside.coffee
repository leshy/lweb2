Backbone = require 'backbone4000'
_ = require 'underscore'
helpers = require 'helpers'

SubscriptionMan2 = require('./../subscriptionman2').SubscriptionMan2

collections = require 'collections/collections'
mongo = require 'collections/serverside/mongo'

callbackMsgEnd = (reply) -> (err,data) -> reply.end err: err, data: data
 
# a mixin that exposes a collection with a standard interface to lweb messaging layer
CollectionExposer = exports.CollectionExposer = SubscriptionMan2.extend4000
    defaults: { name: undefined }
    initialize: ->
        name = @get 'name'
        lweb = @get 'lweb'

        lweb.subscribe collection: name, (msg) => @event msg

        # create
        @subscribe { create: true },
            (msg,reply) => @create msg.create, callbackMsgEnd reply
        
        # remove raw
        @subscribe { remove: true, raw: true  },
            (msg,reply) => @remove msg.remove, callbackMsgEnd reply
        
        # update raw
        @subscribe { update: true, data: true },
            (msg,reply) => @update msg.update, msg.data, callbackMsgEnd reply
            
        # remove
        @subscribe { remove: true },
            (msg,reply,next,transmit) => @findModels(msg.find).each (entry) =>
                if entry? then entry.remove() else reply.end()

        # update
        @subscribe { update: true, data: true },
            (msg,reply) => @findModels(msg.find).each (entry) =>
                if entry? then entry.update(data,msg.realm); entry.flush() else reply.end()
        
        # find
        @subscribe { find: true },
            (msg,reply) => @find msg.find, msg.limits or {}, (entry) =>
                if entry? then reply.write ({ data: entry, err: undefined }) else reply.end()

        # findOne
        @subscribe { findOne: true },
            (msg,reply) => @findOne msg.findOne, (err, entry) =>
                if entry? then reply.write ({ data: entry, err: undefined }) else reply.end()
                
        # call
        @subscribe { call: true, data: true },
            (msg,reply) => @fcall msg.call, msg.args or [], msg.data, msg.realm, (err,data) ->
                if (err or data) then reply.write { err: err, data: data } else reply.end()


exports.MongoCollection = mongo.MongoCollection.extend4000 CollectionExposer, ReferenceMixin, ModelMixin

