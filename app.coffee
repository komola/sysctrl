require("./logger").init()
logger = require('./logger').logger 

logger.use(require('devnull/transports/stream'), {
    stream: require('fs').createWriteStream('logger.log')
})

logger.warning "Test"

express = require("express")
routes = require("./routes")
grafic = require("./routes/grafic")
network = require("./routes/network")
system = require("./routes/system")

app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

app.get "/", routes.index

app.get "/grafic/getResolutions", grafic.getResolutions
app.get "/grafic/setResolution", grafic.setResolution
#app.post "/grafic", grafic.set
app.get "/network/getGateway", network.getGateway
app.get "/network/getInterfaces", network.getInterfaces
app.get "/network/setGateway", network.setGateway
app.get "/network/setInterface", network.setInterface
app.get "/network/getWlanScan", network.getWlanScan
app.get "/network/getWlanStatus", network.getWlanStatus
app.get "/network/setWlan", network.setWlan
app.get "/network/setDhcp", network.setDhcp
app.get "/system/halt", system.halt
app.get "/system/reboot", system.reboot
app.get "/system/restartBrowser", system.restartBrowser

#Only make the API available on the same machine.
#app.listen 3000, 127.0.0.1
app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
