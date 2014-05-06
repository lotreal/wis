'use strict'
api = require('./controllers/api')
index = require('./controllers')
passport = require('./passport')
Model = require('./model')

###
Application routes
###
module.exports = (app) ->
    app.get '/status', (req, res)->
        rid = '1ntlvb7r' # room id
        res.json(
            # Model.team.one(rid).members()
        )

    app.post '/login', (req, res)->
        res.clearCookie('wis:uid')
        passport.login(req.body.name)
        .then(
            (token, uid)->
                req.session.token = token
                passport.verify token, (err, ok)->
                    res.cookie('wis:uid', ok.uid)
                    res.json [null, token: token]

            (err)->
                req.session.token = null
                res.json [err]
        )

    # All undefined api routes should return a 404
    app.get '/api/*', (req, res) ->
        res.send 404
        return

    # All other routes to use Angular routing in app/scripts/app.js
    app.get '/partials/*', index.partials
    app.get '/*', index.index
    return
