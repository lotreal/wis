'use strict'

postal = require('postal')

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

    broadcast: (group, event, data)->
        target = [@]
        postal.publish(
            channel : "connection"
            topic   : "broadcast",
            data    :
                target: target
                event:  event
                data:   data
        )
        return

module.exports = Player
