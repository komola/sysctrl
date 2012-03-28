var sys = require('sys')
var exec = require('child_process').exec;
var child;
/*
 * GET home page.
 */

var os = require("os");

exports.index = function(req, res){
  console.log(os.networkInterfaces());
  res.render('index', { title: 'Express' })
};

exports.getGateway = function(req, res){
  child = exec("ip route | awk '/default/ { print $3 }'", function (error, stdout, stderr) {
	  sys.print('stdout: ' + stdout);
	  sys.print('stderr: ' + stderr);
	  if (error !== null) {
	    console.log('exec error: ' + error);
	  }
	});
};