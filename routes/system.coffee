logger = require('../logger').logger
exec = require("child_process").exec
os = require("os")

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
  await exec "/etc/init.d/nodm restart", defer response.error, response.stdout, response.stderr
  res.json {}
