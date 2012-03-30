express = require("express")
#routes = require("./routes")
#grafic = require("./routes/grafic")
network = require("./routes/network")
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

#app.get "/", routes.index
#app.get "/grafic", grafic.index
#app.post "/grafic", grafic.set
app.get "/network/getGateway", network.getGateway
app.get "/network/getInterfaces", network.getInterfaces
app.get "/network/setGateway", network.setGateway
app.get "/network/setInterface", network.setInterface
app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
