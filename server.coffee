"use strict"
_ = require('lodash')
express = require("express")
session = require('./lib/session')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy

User = require('./lib/models/user').User

log4js = require('log4js')
log4js.configure(
    appenders: [
        {
            type: 'console'
            category: 'log'
        }
        {
            type: 'file'
            filename: 'express.log'
            category: 'express'
        }
    ]
)


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
passport.use new LocalStrategy((username, password, done)->
    console.log username
    User.login username, password, (err, user)->
        if err == 'Invalid user or password.'
            return done(null, false, message: err)
        return done(err) if err
        return done(null, user)
)
passport.serializeUser (user, done)->
    done(null, user.uid)

passport.deserializeUser (uid, done)->
    User.load uid, (err, profile)->
        return done(err) if err
        return done(null, profile)

# Routing
require("./lib/routes") app

logger = log4js.getLogger('log')

# Start server
server.listen config.port, ->
    logger.info "Express server listening on port %d in %s mode", config.port, app.get("env")
    return


# Expose app
exports = module.exports = app
