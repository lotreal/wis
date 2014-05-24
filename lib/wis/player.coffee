'use strict'

Promise = require('bluebird')
User = require('../models/user').User

class Player
    constructor: (@uid) ->
        @ready = false

    getId: ->@uid

    getProfile: (done)->
        self = @
        User.load @getId(), (err, profile)->
            return done(err) if err

            delete profile.uid
            delete profile.password

            self.profile = profile
            return done(err, profile)

    toggleReady: ->
        @ready = !@ready
        return @ready


module.exports = Player
