
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.json(process.env);
};
