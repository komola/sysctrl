
/*
 * GET home page.
 */

var os = require("os");

exports.index = function(req, res){
  console.log(os.networkInterfaces());
  res.render('index', { title: 'Express' })
};

exports.set = function(req, res){
  res.render('index', { title: 'Express' })
};