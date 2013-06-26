// Generated by CoffeeScript 1.4.0
(function() {
  var Backbone, Response, SubscriptionMan2, channelInterface, helpers, queryClient, queryServer, _;

  Backbone = require('backbone4000');

  _ = require('underscore');

  helpers = require('helpers');

  SubscriptionMan2 = exports.SubscriptionMan2 = require('./subscriptionman2').SubscriptionMan2;

  channelInterface = exports.channelInterface = Backbone.Model.extend4000({
    broadcast: function(channel, message) {
      return true;
    },
    join: function(channel, listener) {
      return true;
    },
    part: function(channel, listener) {
      return true;
    },
    del: function() {
      return true;
    }
  });

  Response = (function() {

    function Response(id, client) {
      this.id = id;
      this.client = client;
    }

    Response.prototype.makereply = function(payload, end) {
      var msg;
      if (this.ended) {
        throw 'reply already ended';
      }
      msg = {};
      msg.id = this.id;
      if (payload) {
        msg.payload = payload;
      }
      if (end) {
        msg.end = true;
      }
      return msg;
    };

    Response.prototype.write = function(payload) {
      var reply;
      return this.client.emit('reply', reply = this.makereply(payload));
    };

    Response.prototype.end = function(payload) {
      var reply;
      this.client.emit('reply', reply = this.makereply(payload, true));
      return this.ended = true;
    };

    return Response;

  })();

  queryClient = exports.queryClient = Backbone.Model.extend4000({
    initialize: function() {
      return this.queries = [];
    },
    queryReplyReceive: function(msg) {
      var callback;
      console.log('reply', msg.id, msg.payload);
      if (!(callback = this.queries[msg.id])) {
        return;
      }
      if (!msg.end) {
        return callback(msg.payload, false);
      } else {
        callback(msg.payload, true);
        return delete this.queries[msg.id];
      }
    },
    query: function(msg, callback) {
      var id;
      id = helpers.uuid(10);
      this.queries[id] = callback;
      console.log('query', id, msg);
      this.socket.emit('query', {
        id: id,
        payload: msg
      });
      return true;
    }
  });

  queryServer = exports.queryServer = SubscriptionMan2.extend4000({
    queryReceive: function(msg, client, realm) {
      console.log('got query', msg);
      if (!msg.payload || !msg.id) {
        return console.warn('invalid query message received:', msg);
      }
      return this.event(msg.payload, msg.id, client, realm);
    },
    subscribe: function(pattern, callback) {
      var wrapped;
      if (!callback && pattern.constructor === Function) {
        callback = pattern && (pattern = true);
      }
      wrapped = function(msg, id, client, realm) {
        return callback(msg, new Response(id, client), realm);
      };
      return SubscriptionMan2.prototype.subscribe.call(this, pattern, wrapped);
    }
  });

}).call(this);
