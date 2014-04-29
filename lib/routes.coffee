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
        res.json(
            Model.team.get('team').status()
        )

    app.post '/login', (req, res)->
        passport.login(req.body.name)
        .then(
            (token)->
                req.session.token = token
                res.json [null, token: token]
            (err)->
                req.session.token = null
                res.json [err]
        )

    # Server API Routes
    app.get '/api/awesomeThings', api.awesomeThings

    # All undefined api routes should return a 404
    app.get '/api/*', (req, res) ->
        res.send 404
        return


    # All other routes to use Angular routing in app/scripts/app.js
    app.get '/partials/*', index.partials
    app.get '/*', index.index
    return
