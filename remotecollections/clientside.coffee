Validator = require 'validator2-extras'; v = Validator.v; Select = Validator.Select
Backbone = require 'backbone4000'
helpers = require 'helpers'

collections = require 'collections'

msgCallback = (callback) -> (msg, end) ->
    if not callback then return
    if end then callback msg.err, msg.data

# has the same interface as local collections but it transparently talks to the remote collectionExposer via the messaging system,
RemoteCollection = exports.RemoteCollection = Backbone.Model.extend4000 collections.ModelMixin, collections.ReferenceMixin, Validator.ValidatedModel,
    validator: v(name: "String", lweb: "Instance")

    initialize: ->
        @lweb = @get 'lweb'
        @name = @get 'name'

    create: (entry,callback) ->
        @lweb.query { collection: @name, create: entry }, msgCallback callback
    
    remove: (pattern,callback) ->
        @lweb.query { collection: @name, remove: pattern, raw: true }, msgCallback callback
    
    update: (pattern,data,callback) ->
        @lweb.query { collection: @get('name'), update: pattern, data: data, raw: true }, msgCallback callback
    
    find: (pattern,limits,callback) ->
        @lweb.query { collection: @get('name'), find: pattern, limits: limits }, (msg,end) ->
            if msg then callback(msg.data)
            if end then callback()

    findOne: (pattern,callback) ->
        @lweb.query { collection: @get('name'), findOne: pattern }, (msg,end) ->
            if msg then callback(undefined,msg.data) else callback("not found")

    fcall: (name, args, pattern, callback) ->
        @lweb.query { collection: @get('name'), call: name, args: args, data: pattern }, (msg,end) ->
            helpers.cbc callback, msg.err, msg.data;

