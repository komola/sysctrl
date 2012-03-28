var sys = require('sys')
var exec = require('child_process').exec;
var child;
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Express' })
};

exports.setGateway = function(req, res){
  res.render('index', { title: 'Express' })
  	

	// executes `pwd`
	child = exec("pwd", function (error, stdout, stderr) {
	  sys.print('stdout: ' + stdout);
	  sys.print('stderr: ' + stderr);
	  if (error !== null) {
	    console.log('exec error: ' + error);
	  }
	});
};