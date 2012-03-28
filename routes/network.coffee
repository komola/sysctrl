trim12 = (str) ->
  str = str.replace(/^\s\s*/, "")
  ws = /\s/
  i = str.length
    while ws.test(str.charAt(--i))
  str.slice 0, i + 1
sys = require("sys")
exec = require("child_process").exec
os = require("os")
child = undefined
os = require("os")
exports.index = (req, res) ->
  console.log os.networkInterfaces()
  res.render "index",
    title: "Express"

exports.getInterfaces = (req, res) ->
  interfaces = os.networkInterfaces()
  array = []
  for interface of interfaces
    unless interface is "lo"
      child = exec("ifconfig " + interface + " | sed -rn '2s/ .*:(.*)$/\\1/p'", (error, stdout, stderr) ->
        array.push trim12(stdout)
        console.log trim12(stdout)
        sys.print "stdout: " + stdout
        sys.print "stderr: " + stderr
        console.log "exec error: " + error  if error isnt null
      )
      console.log interface
  res.json os.networkInterfaces()

exports.getGateway = (req, res) ->
  child = exec("ip route | awk '/default/ { print $3 }'", (error, stdout, stderr) ->
    res.json trim12(stdout)
    sys.print "stdout: " + stdout
    sys.print "stderr: " + stderr
    console.log "exec error: " + error  if error isnt null
  )