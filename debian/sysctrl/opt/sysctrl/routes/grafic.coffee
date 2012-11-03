logger = require('../logger').logger
exec = require("child_process").exec
os = require("os")

exports.getResolutions = (req, res) ->
  exec "xrandr -d :0.0 -q", (error, stdout, stderr) ->
    response = {'error': error, 'stdout': stdout, 'stderr': stderr}
    resolutionsRaw = response.stdout.split("\n")
    #  console.log(resolutionsRaw)
    resolutions = []
    for r in resolutionsRaw
      currentResolution = r.trim().split(/\s+/g)
      if(currentResolution[0].match(/(\d+)x(\d+)/))
        frequencies = []
        for currentFrequency in currentResolution.splice(1)
          frequencies.push currentFrequency

        resolutions.push({
          resolution: currentResolution[0].split("x"),
          frequency: frequencies
        })
    res.json(resolutions)

exports.setResolution = (req, res) ->
  exec "xrandr -display :0.0 -s 1650x1080", (error, stdout, stderr) ->
    exports.getResolutions(req, res)
