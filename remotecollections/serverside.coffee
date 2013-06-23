Backbone = require 'backbone4000'
_ = require 'underscore'
helpers = require 'helpers'

SubscriptionMan2 = require('./../subscriptionman2').SubscriptionMan2

collections = require 'collections'
mongo = require 'collections/serverside/mongodb'

callbackMsgEnd = (reply) -> (err,data) -> reply.end err: err, data: data
 
# a mixin that exposes a collection with a standard interface to lweb messaging layer
CollectionExposer = exports.CollectionExposer = Backbone.Model.extend4000
    defaults: { name: undefined }
    initialize: ->
        name = @get 'name'
        lweb = @get 'lweb'
        
        # create
        lweb.subscribe { collection: name, create: true },
            (msg,reply) =>
                console.log 'create msg received',msg
                @create msg.create, callbackMsgEnd reply
        
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
            (msg,reply) => @fcall msg.call, msg.args or [], msg.data, msg.realm, (err,data) ->
                if (err or data) then reply.write { err: err, data: data } else reply.end()
        

exports.MongoCollection = mongo.MongoCollection.extend4000 CollectionExposer, collections.ReferenceMixin, collections.ModelMixin

