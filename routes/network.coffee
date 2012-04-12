logger = require('../logger').logger
exec = require("child_process").exec
os = require("os")

trim11 = (str) ->
  str = str.replace(/^\s+/, "")
  i = str.length - 1

  while i >= 0
    if /\S/.test(str.charAt(i))
      str = str.substring(0, i + 1)
      break
    i--
  str

returnGateway = (cb) ->
  await
    response = {}
    exec "ip route | awk '/default/ { print $3 }'", defer response.error, response.stdout, response.stderr
  logger.log response.stdout
  cb trim11(response.stdout)

exports.index = (req, res) ->
  console.log os.networkInterfaces()
  res.render "index",
    title: "Express"

exports.setGateway = (req, res) ->
  await returnGateway defer gateway
  response = {}
  if gateway
    await exec "route del default gw "+gateway, defer response.error, response.stdout, response.stderr
  await exec "route add default gw 192.168.1.1", defer response.error, response.stdout, response.stderr
  exports.getGateway req, res

exports.getWlanScan = (req, res) ->
  response = {}
  await exec "wpa_cli scan_results", defer response.error, response.stdout, response.stderr
  scanResultsRaw = response.stdout.split("\n")
  console.log(scanResultsRaw)
  scanResults = []
  for i in scanResultsRaw
    scanResult = i.split "\t"
    if scanResult[0].split(":").length == 6 # Checks if first array entry is a mac address
      scanResults.push({
        mac: scanResult[0],
        freqency: scanResult[1],
        signal: scanResult[2],
        flags: scanResult[3].match(/[^\][[^\]]*/g).filter((e) -> e),
        ssid: scanResult[4]
      })
    
  res.json(scanResults)

exports.setDhcp = (req, res) ->
  response = {}
  #await exec "dhclient "+req.params.interface, defer response.error, response.stdout, response.stderr
  exports.getInterfaces req, res

exports.setInterface = (req, res) ->
  response = {}
  #await exec "ifconfig "+req.params.interface+" "+req.params.ip+" netmask "+req.params.netmask, defer response.error, response.stdout, response.stderr
  exports.getInterfaces req, res

exports.getInterfaces = (req, res) ->
  networkInterfaces = os.networkInterfaces()
  array = []
  await 
    for networkInterface, i of networkInterfaces when networkInterface != "lo"
      response = {}
      exec "ifconfig " + networkInterface + " | sed -rn '2s/ .*:(.*)$/\\1/p'", defer response.error, response.stdout, response.stderr
      array[networkInterface] = response

  for networkInterface, value of array
    do(networkInterface, value) ->
      # Only add the gateway when we have a IPv4 network
      a.gateway = trim11 value.stdout for a in networkInterfaces[networkInterface] when a.family is "IPv4"

  res.json networkInterfaces

exports.getGateway = (req, res) ->
  await returnGateway defer gateway
  res.json gateway
