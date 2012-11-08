logger = require('../logger').logger
exec = require("child_process").exec
os = require("os")
async = require("async")

trim11 = (str) ->
  str = str.replace(/^\s+/, "")
  i = str.length - 1

  while i >= 0
    if /\S/.test(str.charAt(i))
      str = str.substring(0, i + 1)
      break
    i--
  str

isIP = (obj) ->
  ary = obj.value.split(".")
  ip = true
  for i of ary
    ip = (if (not ary[i].match(/^\d{1,3}$/) or (Number(ary[i]) > 255)) then false else ip)
  ip = (if (ary.length isnt 4) then false else ip)
  unless ip # the value is NOT a valid IP address
    return true
  else # the value IS a valid IP address
    return false

returnGateway = (cb) ->
  exec "ip route | awk '/default/ { print $3 }'", (error, stdout, stderr) ->
    logger.log stdout
    cb trim11(stdout)

returnWlanScan = (cb) ->
  # Get current Accesspoints
  exec "wpa_cli scan_results", (error, stdout, stderr) ->
    scanResultsRaw = stdout.split("\n")
    console.log(scanResultsRaw)
    scanResults = {}
    for i in scanResultsRaw
      scanResult = i.split "\t"
      if scanResult[0].split(":").length == 6 # Checks if first array entry is a mac address
        scanResults[scanResult[4]] = {
          mac: scanResult[0],
          freqency: scanResult[1],
          signal: scanResult[2],
          flags: scanResult[3].match(/[^\][[^\]]*/g).filter((e) -> e),
          ssid: scanResult[4]
        }
    console.log scanResults

    cb scanResults

exports.index = (req, res) ->
  console.log os.networkInterfaces()
  res.render "index",
    title: "Express"


exports.setGateway = (req, res) ->
  returnGateway((gateway) ->
    gatewayIP = req.body.ip
    if isIP(gatewayIP)
      async.waterfall([
        (callback) ->
          if gateway
            exec "route del default gw "+gateway, (error, stdout, stderr) ->
              callback(null)
          else
            callback(null)
        ,(callback) ->
          exec "route add default gw "+gatewayIP, (error, stdout, stderr) ->
            exports.getGateway req, res
            callback(null)
      ])
  )

exports.setWlan = (req, res) ->
  returnWlanScan((scanResults) ->
    currentWlan = scanResults[req.body.ssid]
    if(currentWlan)
      console.log currentWlan
      exec "wpa_cli reconfigure && wpa_cli add_network && wpa_cli set_network 0 ssid '\""+currentWlan['ssid']+"\"'", (error, stdout, stderr) ->

        async.waterfall([
          (callback) ->
            if(currentWlan.flags.length == 0 || currentWlan.flags.indexOf("WEP") != -1)
              exec "wpa_cli set_network 0 key_mgmt NONE", (error, stdout, stderr) ->
                callback(null)
            else
              callback(null)
          ,
          (callback) ->
            if(currentWlan.flags.indexOf("WEP") != -1)
              exec "wpa_cli set_network 0 wep_key0 "+req.body.password, (error, stdout, stderr) ->
                callback(null)
            else
              exec "wpa_cli set_network 0 psk '\""+req.body.password+"\"'", (error, stdout, stderr) ->
                callback(null)
          ], (error) ->
            exec "wpa_cli select_network 0", (error, stdout, stderr) ->
              res.json currentWlan
          )
    else
      res.json {}
  )

exports.getWlanScan = (req, res) ->
  returnWlanScan((scanResults) ->
    res.json(scanResults)
  )

exports.scanWlan = (req, res) ->
  exec "wpa_cli scan", (eror, stdout, stderr) ->
    res.json true

exports.getWlanStatus = (req, res) ->
  console.log "test"
  exec "wpa_cli status", (error, stdout, stderr) ->
    statusRaw = stdout.split("\n")
    statusResult = {}
    for i in statusRaw
      status = i.split("=")
      statusResult[status[0]] = status[1] if status[1]
    res.json(statusResult)

exports.setDhcp = (req, res) ->
  exec "dhclient wlan0", (error, stdout, stderr) ->
    exports.getInterfaces req, res

exports.setInterface = (req, res) ->
  async.waterfall([
    (callback) ->
      if ( req.body.interface == "eth0" || req.body.interface == "wlan1" ) && (req.body.ip) && isIP(req.body.netmask)
        exec "ifconfig "+req.body.interface+" "+req.body.ip+" netmask "+req.body.netmask, (error, stdout, stderr) ->
          callback(null)
      else
        callback(null)
    ,(callback) ->
      exports.getInterfaces req, res
  ])


exports.getInterfaces = (req, res) ->
  networkInterfaces = os.networkInterfaces()
  array = []
  async.waterfall([
    (callback) ->
      runs = 0
      for networkInterface, i of networkInterfaces when networkInterface != "lo"
        ++runs
        exec "ifconfig " + networkInterface + " | sed -rn '2s/ .*:(.*)$/\\1/p'", (error, stdout, stderr) ->
          array[networkInterface] = {'stdout': stdout, 'error': error, 'stderr': stderr}
          if --runs <= 0
            callback(null)
    ,(callback) ->
      runs = 0
      for networkInterface, value of array
        ++runs
        do(networkInterface, value) ->
          # Only add the gateway when we have a IPv4 network
          a.gateway = trim11 value.stdout for a in networkInterfaces[networkInterface] when a.family is "IPv4"
          if --runs <= 0
            callback(null)
    ], (error) ->
      res.json networkInterfaces
    )

exports.getGateway = (req, res) ->
  returnGateway((gateway) ->
    res.json gateway
  )
