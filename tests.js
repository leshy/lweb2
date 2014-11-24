// Generated by CoffeeScript 1.7.1
(function() {
  var Http, Lwebc, Lwebs, express, gimmeEnv, helpers, port, shared;

  Lwebs = require('./serverside');

  Lwebc = require('./clientside');

  shared = require('./shared');

  helpers = require('helpers');

  express = require('express');

  Http = require('http');

  port = 8192;

  gimmeEnv = function(callback) {
    var app, http, lwebc, lwebs;
    app = express();
    app.configure(function() {
      app.set('view engine', 'ejs');
      app.use(express.favicon());
      app.use(express.bodyParser());
      app.use(express.methodOverride());
      app.use(express.cookieParser());
      app.use(app.router);
      return app.use(function(err, req, res, next) {
        return res.send(500, 'BOOOM!');
      });
    });
    http = Http.createServer(app);
    http.listen(++port);
    lwebs = new Lwebs.lweb({
      http: http
    });
    lwebc = new Lwebc.lweb({
      host: 'http://localhost:' + port
    });
    return lwebs.server.on('connection', function() {
      return callback(lwebs, lwebc, http, function(test) {
        lwebc.socket.disconnect();
        return http.close(function() {
          return test.done();
        });
      });
    });
  };

  exports.connect = function(test) {
    return gimmeEnv(function(lwebs, lwebc, http, done) {
      return done(test);
    });
  };

  exports.query = function(test) {
    return gimmeEnv(function(lwebs, lwebc, http, done) {
      lwebs.subscribe({
        bla: true
      }, function(query, realm, reply) {
        test.deepEqual(query, {
          bla: 33
        });
        return done(test);
      });
      return lwebc.query({
        bla: 33
      });
    });
  };

  exports.queryReply = function(test) {
    return gimmeEnv(function(lwebs, lwebc, http, done) {
      lwebs.subscribe({
        bla: true
      }, function(query, reply) {
        test.deepEqual(query, {
          bla: 33
        });
        return reply.end({
          blu: 66
        });
      });
      return lwebc.query({
        bla: 33
      }, function(reply) {
        test.deepEqual(reply, {
          blu: 66
        });
        return done(test);
      });
    });
  };

  exports.queryStreamReply = function(test) {
    return gimmeEnv(function(lwebs, lwebc, http, done) {
      var total;
      lwebs.subscribe({
        bla: true
      }, function(query, reply) {
        test.deepEqual(query, {
          bla: 33
        });
        helpers.wait(10, function() {
          return reply.write({
            r: 2
          });
        });
        helpers.wait(30, function() {
          return reply.write({
            r: 6
          });
        });
        helpers.wait(50, function() {
          return reply.write({
            r: 1
          });
        });
        return helpers.wait(90, function() {
          return reply.end({
            r: 88
          });
        });
      });
      total = 0;
      return lwebc.query({
        bla: 33
      }, function(reply, end) {
        total += reply.r;
        if (end) {
          test.deepEqual(reply, {
            r: 88
          });
          test.equal(total, 97);
          return done(test);
        }
      });
    });
  };

  exports.channels = function(test) {
    return gimmeEnv(function(lwebs, lwebc, http, done) {
      lwebc.channel('bla').join();
      lwebc.channels.bla.subscribe({
        bla: true
      }, function(msg) {
        return done(test);
      });
      return helpers.wait(50, function() {
        return lwebs.channels.bla.broadcast({
          bla: 3
        });
      });
    });
  };

  exports.basic = function(test) {
    var lwebc, lwebs;
    test.done();
    return;
    lwebs = lwebs.listen();
    lwebc = lwebc.connect();
    lwebc.channels.on('channel1', function(msg) {
      return console.log('channel msg', msg);
    });
    lwebs.channels.broadcast('channel1', {
      message: 'test message1'
    });
    lwebs.subscribe({
      bla: true
    }, function(msg, response, client) {
      response.write({
        response: 1
      });
      response.write({
        response: 2
      });
      return response.end({
        response: 3
      });
    });
    lwebc.query({
      bla: 3
    }, function(err, msg) {
      return console.log('got', msg);
    });
    return lwebc.multiQuery({
      bla: 3
    }, function(err, data) {
      return true;
    });
  };

  exports.SimpleSubscriptionMan = function(test) {
    var a;
    a = new shared.SubscriptionMan();
    a.subscribe({
      bla: true
    }, function(msg) {
      return test.done();
    });
    return a.event({
      bla: 'test1'
    });
  };

  exports.SimpleSubscriptionMan_fail = function(test) {
    var a;
    a = new shared.SubscriptionMan();
    a.subscribe({
      bla: 'testx'
    }, function(msg) {
      return test.fail();
    });
    a.event({
      bla: 'test1'
    });
    return test.done();
  };

  exports.SimpleSubscriptionMan_exact = function(test) {
    var a;
    a = new shared.SubscriptionMan();
    a.subscribe({
      bla: 'test1'
    }, function(msg) {
      return test.done();
    });
    return a.event({
      bla: 'test1'
    });
  };

}).call(this);
