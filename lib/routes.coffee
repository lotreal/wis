'use strict'

passport = require('passport')

api = require('./controllers/api')
index = require('./controllers')
# passport = require('./passport')
Model = require('./model')
Player = require('./wis/player')

ensureAuthenticated = (req, res, next)->
    return next() if req.isAuthenticated()

    req.session.goingTo = req.url
    res.redirect "/signin"

###
Application routes
###
module.exports = (app) ->
    app.get '/status', (req, res)->
        rid = '1ntlvb7r' # room id
        res.json(
            # Model.team.one(rid).members()
        )

    app.get '/logout', (req, res)->
        req.logout();
        res.json [null, '/signin']

    app.post '/login', (req, res, next)->
        console.log 'start login...'

        passport.authenticate('local', (err, user, info)->
            return res.json [err] if err
            return res.json [info.message] if !user
            req.logIn user, ->
                return res.json [err] if err
            # if req.body.rememberme
            #     req.session.cookie.maxAge = 1000 * 60 * 60 * 24 * 7
            res.json [null]
        )(req, res, next)
        # res.clearCookie('wis:uid')
        # passport.login(req.body.name)
        # .then(
        #     (token, uid)->
        #         req.session.token = token
        #         passport.verify token, (err, ok)->
        #             res.cookie('wis:uid', ok.uid)
        #             res.json [null, token: token]

        #     (err)->
        #         req.session.token = null
        #         res.json [err]
        # )

    app.post '/api/room', api.getRoom

    # All undefined api routes should return a 404
    app.get '/api/*', (req, res) ->
        res.send 404
        return

    # All other routes to use Angular routing in app/scripts/app.js
    app.get '/partials/*', index.partials

    app.get '/signin', index.index
    app.get '/*', ensureAuthenticated, index.index
    return
