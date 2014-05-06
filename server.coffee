"use strict"
_ = require('lodash')
express = require("express")
session = require('./lib/session')


###
Main application file
###

# Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV or "development"

# Application Config
config = require("./lib/config/config")
app = express()
http = require("http")
server = http.createServer(app)

# Socket.io
socket = require("./lib/socket.js")
io = require("socket.io").listen(server)

require('./lib/config/socket') io

# SessionSockets = require('session.socket.io')
# sessionSockets = new SessionSockets(io, session.sessionStore, session.cookieParser, session.key)
# sessionSockets.on('connection', (err, socket, session)->
#     session.foo = 'bar'
#     session.save()
#     console.log session: session
# )
require('./lib/passport').socket(io)
io.sockets.on "connection", socket

# Express settings
require("./lib/config/express") app

# Routing
require("./lib/routes") app

# Start server
server.listen config.port, ->
    console.log "Express server listening on port %d in %s mode", config.port, app.get("env")
    return


# Expose app
exports = module.exports = app
