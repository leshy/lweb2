// Generated by CoffeeScript 1.4.0
(function() {
  var Backbone, Channel, ChannelServer, SubscriptionMan, helpers, io, lweb, shared, _;

  io = require('socket.io');

  Backbone = require('backbone4000');

  SubscriptionMan = require('subscriptionman').SubscriptionMan;

  helpers = require('helpers');

  _ = require('underscore');

  _.extend(exports, shared = require('./shared'));

  Channel = shared.channelInterface.extend4000({
    initialize: function() {
      this.name = this.get('name' || (function() {
        throw 'channel needs a name';
      })());
      return this.subscribers = {};
    },
    subscribe: function(client) {
      var _this = this;
      this.subscribers[client.id] = client;
      return client.on('disconnect', function() {
        return _this.unsubscribe(client);
      });
    },
    unsubscribe: function(client) {
      delete this.subscribers[client.id];
      if (_.isEmpty(this.subscribers)) {
        return this.del();
      }
    },
    broadcast: function(msg, exclude) {
      var _this = this;
      return _.map(this.subscribers, function(subscriber) {
        if (subscriber !== exclude) {
          return subscriber.emit(_this.name, msg);
        }
      });
    },
    del: function() {
      this.subscribers = {};
      return this.trigger('del');
    }
  });

  ChannelServer = shared.channelInterface.extend4000({
    initialize: function() {
      return this.channels = {};
    },
    broadcast: function(channelname, msg) {
      var channel;
      console.log('broadcast', channelname, msg);
      if (!(channel = this.channels[channelname])) {
        return;
      }
      return channel.broadcast(msg);
    },
    subscribe: function(channelname, client) {
      var channel,
        _this = this;
      console.log('subscribe to', channelname);
      if (!(channel = this.channels[channelname])) {
        channel = this.channels[channelname] = new Channel({
          name: channelname
        });
        channel.on('del', function() {
          return delete _this.channels[channelname];
        });
      }
      return channel.subscribe(client);
    },
    unsubscribe: function(channelname, socket) {
      var channel;
      if (!(channel = this.channels[channelname])) {
        return;
      }
      return channel.unsubscribe(socket);
    }
  });

  lweb = exports.lweb = shared.lwebInterface.extend4000(ChannelServer, {
    listen: function(http) {
      var loopy, options,
        _this = this;
      if (http == null) {
        http = this.get('http', options = this.get('options'));
      }
      this.server = io.listen(http, options || {});
      this.server.on('connection', function(client) {
        var host, id;
        id = client.id;
        host = client.handshake.address.address;
        console.log('got connection from', host, id);
        client.on('subscribe', function(msg) {
          return _this.subscribe(msg.channel, client);
        });
        client.on('unsubscribe', function(msg) {
          return _this.unsubscribe(msg.channel, client);
        });
        return client.on('disconnect', function() {
          return _.map(client.channels, function(channel) {
            return _this.unsubscribe(channel, client);
          });
        });
      });
      loopy = function() {
        _this.broadcast('testchannel', {
          ping: new Date().getTime()
        });
        return helpers.sleep(1000, loopy);
      };
      return loopy();
    }
  });

}).call(this);
