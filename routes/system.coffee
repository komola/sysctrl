logger = require('../logger').logger
exec = require("child_process").exec
os = require("os")
restler = require("restler")
path = require("path")
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


returnPartitions = (cb) ->
  response = {}
  await exec "blkid -c /dev/null -o export /dev/sda*", defer response.error, response.stdout, response.stderr
  systemPartitionsRaw = response.stdout.split("\n\n")
  systemPartitionsNice = {}
  for i, count in systemPartitionsRaw
    #console.log i, count
    attributes = i.split("\n")
    for attribute in attributes
      if attribute != ""
        attributeVars = attribute.split("=")
        if(attributeVars[0] == "UUID")
          systemPartitionsNice[attributeVars[1]] = true

  await exec "blkid -c /dev/null -o export", defer response.error, response.stdout, response.stderr
  partitionsRaw = response.stdout.split("\n\n")
  partionsNice = []
  for i, count in partitionsRaw
    #console.log i, count
    cache = {}
    systemDisk = false;
    attributes = i.split("\n")
    for attribute in attributes
      if attribute != ""
        attributeVars = attribute.split("=")
        cache[attributeVars[0]] = attributeVars[1]
        if(attributeVars[0] == "UUID" && systemPartitionsNice[attributeVars[1]])
          systemDisk = true

    if(systemDisk == false)
      await exec "fdisk -s /dev/disk/by-uuid/"+cache["UUID"], defer response.error, response.stdout, response.stderr
      cache.space = response.stdout.replace(/^\s+/, '').replace(/\s+$/, '')*1024;
      partionsNice.push(cache)

  console.log partionsNice
  cb partionsNice

exports.getPartitions = (req, res) ->
  await returnPartitions defer partitionResult
  res.json(partitionResult)

exports.copyPartition = (req, res) ->
  timestamp = new Date().getTime()
  response = {}
  umountResponse = {}
  tempDeviceUUID = req.body.deviceUUID.replace(/^\s+/, '').replace(/\s+$/, '')
  await returnPartitions defer partitionResult
  for partition in partitionResult
    if partition.UUID == tempDeviceUUID
      deviceUUID = partition.UUID

  tempCopyToPath = req.body.copyTo
  
  copyToPath = path.resolve("/opt/incoming/")

  if path.resolve(tempCopyToPath).substr("/opt/incoming/") == 0
    copyToPath = path.resolve(tempCopyToPath)

  if deviceUUID
    await exec 'umount -f /dev/disk/by-uuid/'+deviceUUID, defer umountResponse.error, umountResponse.stdout, umountResponse.stderr
    await exec 'mkdir /mnt/'+timestamp+' && mount /dev/disk/by-uuid/'+deviceUUID+' /mnt/'+timestamp+' && rsync -a --include "*/" /mnt/'+timestamp+' '+copyToPath+'/'+timestamp+'/ && umount -f /mnt/'+timestamp+' && rmdir /mnt/'+timestamp, defer response.error, response.stdout, response.stderr
    if(response.error)
      res.json response
    else
      res.json "success"

  else
    res.json "error"