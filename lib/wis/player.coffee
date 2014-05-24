'use strict'

Promise = require('bluebird')
User = require('../models/user').User

class Player
    constructor: (@uid) ->
        @ready = false

    getId: ->@uid

    toggleReady: ->
        @ready = !@ready
        return @ready

    getProfile: (done)->
        self = @
        User.load @getId(), (err, profile)->
            return done(err) if err

            delete profile.uid
            delete profile.password

            self.profile = profile
            return done(err, profile)

    # TODO cache
    fillout: ->
        self = @
        return new Promise (resolve, reject)->
            User.load self.getId(), (err, profile)->
                # return done(err) if err
                delete profile.uid
                delete profile.password

                self.profile = profile
                resolve self

module.exports = Player
