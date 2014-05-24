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

    # TODO cache
    fillout: ->
        self = @
        return new Promise (resolve, reject)->
            User.loadProfile self.getId(), (err, profile)->
                self.profile = profile
                resolve self

module.exports = Player
