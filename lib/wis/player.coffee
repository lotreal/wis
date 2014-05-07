'use strict'

Promise = require('bluebird')
User = require('../model').user

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
            User.id(self.uid).then (user)->
                self.profile = user.profile
                resolve self

module.exports = Player
