logger = require('../logger').logger
exec = require("child_process").exec
os = require("os")
restler = require("restler")
Websocket = require("ws")

exports.halt = (req, res) ->
  response = {}
  await exec "halt", defer response.error, response.stdout, response.stderr
  res.json {}

exports.reboot = (req, res) ->
  response = {}
  await exec "reboot", defer response.error, response.stdout, response.stderr
  res.json {}

exports.reloadPage = (req, res) ->
  await restler.get('http://localhost:9222/json').on 'complete', defer result  
  if(result.length > 0)
    runs = 0
    for i in result
      ++runs
      websocket = new Websocket(i.webSocketDebuggerUrl)
      websocket.on 'open', ->
        websocket.send '{"id":1,"method":"Page.reload","params": {"ignoreCache":false}}'
        # only gets executed when all callbacks are finished
        if --runs <= 0
          res.json {}
  else
    exports.restartBrowser(req, res)

exports.restartBrowser = (req, res) ->
  response = {}
  await exec "/etc/init.d/nodm restart", defer response.error, response.stdout, response.stderr
  res.json {}
