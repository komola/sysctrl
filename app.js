/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , grafic = require('./routes/grafic')
  , network = require('./routes/network');

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'ejs');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Routes

app.get('/', routes.index);
app.get('/grafic', grafic.index);
app.post('/grafic', grafic.set);
app.get('/network', network.index);
app.post('/network/getGateway', network.getGateway);

app.listen(3000);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
