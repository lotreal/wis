'use strict'

Promise = require('bluebird')
User = require('../model').user

class Player
    constructor: (@uid) ->

    getId: ->@uid

    fillout: ->
        self = @
        return new Promise (resolve, reject)->
            User.id(self.uid).then (user)->
                self.profile = user.profile
                resolve self

module.exports = Player
