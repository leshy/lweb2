// Generated by CoffeeScript 1.7.1
(function() {
  var Backbone, Channel, ChannelClient, Select, Validator, collections, helpers, io, lweb, shared, v, _;

  Validator = require('validator2-extras');

  v = Validator.v;

  Select = Validator.Select;

  Backbone = require('backbone4000');

  io = require('socket.io-browserify');

  helpers = require('helpers');

  _ = require('underscore');

  _.extend(exports, shared = require('./shared'));

  _.extend(exports, collections = require('./remotecollections/clientside'));

  Channel = exports.Channel = shared.SubscriptionMan.extend4000({
    validator: v({
      name: "String",
      lweb: "Instance"
    }),
    initialize: function() {
      this.name = this.get('name' || (function() {
        throw 'channel needs a name';
      })());
      this.socket = this.get('lweb').socket || (function() {
        throw 'channel needs lweb';
      })();
      this.socket.on(this.name, (function(_this) {
        return function(msg) {
          return _this.event(msg);
        };
      })(this));
      this.on('unsubscribe', (function(_this) {
        return function() {
          if (!_.keys(_this.subscriptions).length) {
            return _this.part();
          }
        };
      })(this));
      return this.on('subscribe', function() {
        if (!this.joined) {
          return this.join();
        }
      });
    },
    join: function() {
      if (this.joined) {
        return;
      }
      console.log('join to', '#' + this.name);
      this.socket.emit('join', {
        channel: this.name
      });
      return this.joined = true;
    },
    part: function() {
      if (!this.joined) {
        return;
      }
      console.log('part from', '#' + this.name);
      this.socket.emit('part', {
        channel: this.name
      });
      return this.joined = false;
    },
    del: function() {
      this.part();
      return this.trigger('del');
    }
  });

  ChannelClient = shared.channelInterface.extend4000({
    ChannelClass: Channel
  });

  lweb = exports.lweb = ChannelClient.extend4000(shared.queryClient, shared.queryServer, {
    initialize: function() {
      if (typeof window !== "undefined" && window !== null) {
        if (typeof window === "function") {
          window(lweb = this);
        }
      }
      this.socket = io.connect(this.get('host') || "http://" + (typeof window === "function" ? window(typeof location === "function" ? location(host) : void 0) : void 0));
      this.socket.on('query', (function(_this) {
        return function(msg) {
          return _this.queryReceive(msg, _this.socket);
        };
      })(this));
      return this.socket.on('reply', (function(_this) {
        return function(msg) {
          return _this.queryReplyReceive(msg, _this.socket);
        };
      })(this));
    },
    collection: function(name) {
      return new exports.RemoteCollection({
        lweb: this,
        name: name
      });
    }
  });

}).call(this);
