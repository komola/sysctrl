exports.halt = (req, res) ->
  response = {}
  await exec "halt", defer response.error, response.stdout, response.stderr
  res.json {}

exports.reboot = (req, res) ->
  response = {}
  await exec "reboot", defer response.error, response.stdout, response.stderr
  res.json {}

exports.restartBrowser = (req, res) ->
  response = {}
  await exec "/etc/init.d/nodm", defer response.error, response.stdout, response.stderr
  res.json {}
