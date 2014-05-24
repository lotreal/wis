"use strict"

express = require("express")
log4js = require('log4js')
path = require("path")
passport = require('passport')

config = require("./config")
session = require('../session')

###
Express configuration
###
module.exports = (app) ->
    app.configure "development", ->
        app.use require("connect-livereload")()

        # Disable caching of scripts for easier testing
        app.use noCache = (req, res, next) ->
            if req.url.indexOf("/scripts/") is 0
                res.header "Cache-Control", "no-cache, no-store, must-revalidate"
                res.header "Pragma", "no-cache"
                res.header "Expires", 0
            next()
            return

        app.use express.static(path.join(config.root, ".tmp"))
        app.use express.static(path.join(config.root, "app"))
        app.set "views", config.root + "/app/views"
        return

    app.configure "production", ->
        app.use express.compress()
        app.use express.favicon(path.join(config.root, "public", "favicon.ico"))
        app.use express.static(path.join(config.root, "public"))
        app.set "views", config.root + "/views"
        # logger = log4js.getLogger('express')
        # logger.setLevel('ERROR')
        # app.use log4js.connectLogger(logger, level: 'auto')
        return

    app.configure ->
        app.engine "html", require("ejs").renderFile
        app.set "view engine", "html"
        app.use express.logger("dev")
        app.use express.json()
        app.use express.urlencoded()
        app.use express.methodOverride()
        app.use session.cookieParser
        app.use express.bodyParser()
        app.use express.session(store: session.sessionStore, secret: session.secret, key: session.key)
        app.use passport.initialize()
        app.use passport.session()
        # Router (only error handlers should come after this)
        app.use app.router
        app.use express.csrf()
        app.use (req, res, next)->
            res.locals.csrftoken = req.csrfToken()
            next()
        app.disable 'x-powered-by'
        return


    # Error handler
    app.configure "development", ->
        app.use express.errorHandler()
        return

    return
