// Generated by CoffeeScript 1.4.0
(function() {
  var Backbone, CollectionExposer, SubscriptionMan2, callbackMsgEnd, collections, helpers, mongo, _;

  Backbone = require('backbone4000');

  _ = require('underscore');

  helpers = require('helpers');

  SubscriptionMan2 = require('./../subscriptionman2').SubscriptionMan2;

  collections = require('collections');

  mongo = require('collections/serverside/mongodb');

  callbackMsgEnd = function(reply) {
    return function(err, data) {
      return reply.end({
        err: err,
        data: data
      });
    };
  };

  CollectionExposer = exports.CollectionExposer = Backbone.Model.extend4000({
    defaults: {
      name: void 0
    },
    initialize: function() {
      var lweb, name,
        _this = this;
      name = this.get('name');
      lweb = this.get('lweb');
      lweb.subscribe({
        collection: name,
        create: true
      }, function(msg, reply) {
        console.log('create msg received', msg);
        return _this.create(msg.create, callbackMsgEnd(reply));
      });
      lweb.subscribe({
        collection: name,
        remove: true,
        raw: true
      }, function(msg, reply) {
        return _this.remove(msg.remove, callbackMsgEnd(reply));
      });
      lweb.subscribe({
        collection: name,
        update: true,
        data: true,
        raw: true
      }, function(msg, reply) {
        return _this.update(msg.update, msg.data, callbackMsgEnd(reply));
      });
      lweb.subscribe({
        collection: name,
        remove: true
      }, function(msg, reply) {
        return _this.findModels(msg.remove, {}, function(entry) {
          if (entry != null) {
            return entry.remove();
          } else {
            return reply.end();
          }
        });
      });
      lweb.subscribe({
        collection: name,
        update: true,
        data: true
      }, function(msg, reply) {
        return _this.findModels(msg.update, {}, function(entry) {
          if (entry != null) {
            entry.update(data, 'public');
            return entry.flush();
          } else {
            return reply.end();
          }
        });
      });
      lweb.subscribe({
        collection: name,
        find: true
      }, function(msg, reply) {
        return _this.find(msg.find, msg.limits || {}, function(entry) {
          if (entry != null) {
            return reply.write({
              data: entry,
              err: void 0
            });
          } else {
            return reply.end();
          }
        });
      });
      lweb.subscribe({
        collection: name,
        findOne: true
      }, function(msg, reply) {
        _this.findOne(msg.findOne, function(err, entry) {});
        if (typeof entry !== "undefined" && entry !== null) {
          return reply.write({
            data: entry,
            err: void 0
          });
        } else {
          return reply.end();
        }
      });
      return lweb.subscribe({
        collection: name,
        call: true,
        data: true
      }, function(msg, reply) {
        return _this.fcall(msg.call, msg.args || [], msg.data, 'somerealm', function(err, data) {
          return reply.end({
            err: err,
            data: data
          });
        });
      });
    }
  });

  exports.MongoCollection = mongo.MongoCollection.extend4000(CollectionExposer, collections.ReferenceMixin, collections.ModelMixin);

}).call(this);
