// Generated by CoffeeScript 1.4.0
(function() {
  var RemoteCollection;

  RemoteCollection = exports.RemoteCollection = Backbone.Model.extend4000(ModelMixin, ReferenceMixin, SubscriptionMixin, Validator.ValidatedModel, MsgNode, {
    validator: v({
      name: "String"
    }),
    create: function(entry, callback) {
      return core.msgCallback(this.send({
        collection: this.get('name'),
        create: entry
      }), callback);
    },
    remove: function(pattern, callback) {
      return core.msgCallback(this.send({
        collection: this.get('name'),
        remove: pattern,
        raw: true
      }), callback);
    },
    update: function(pattern, data, callback) {
      return core.msgCallback(this.send({
        collection: this.get('name'),
        update: pattern,
        data: data,
        raw: true
      }), callback);
    },
    find: function(pattern, limits, callback) {
      var reply;
      reply = this.send({
        collection: this.get('name'),
        find: pattern,
        limits: limits
      });
      return reply.read(function(msg) {
        if (msg) {
          return callback(msg.data);
        } else {
          return callback();
        }
      });
    },
    findOne: function(pattern, callback) {
      var reply;
      reply = this.send({
        collection: this.get('name'),
        findOne: pattern
      });
      return reply.read(function(msg) {
        if (msg) {
          return callback(void 0, msg.data);
        } else {
          return callback("not found");
        }
      });
    },
    fcall: function(name, args, pattern, callback) {
      var reply;
      reply = this.send({
        collection: this.get('name'),
        call: name,
        args: args,
        data: pattern
      });
      return reply.read(function(msg) {
        if (msg) {
          return helpers.cbc(callback, msg.err, msg.data);
        }
      });
    }
  });

}).call(this);
