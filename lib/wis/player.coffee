'use strict'

Promise = require('bluebird')
User = require('../model').user

class Player
    constructor: (options) ->
        @id = options.uid
        @socketID = options.socketID
        @io = options.io
        @state = 'OK'

    getId: ->@id

    getSocket: ->
        @io.sockets.sockets[@socketID]

    setSocket: (socket)->
        @socketID = socket.id
        return socket

    fillout: ->
        self = @
        return new Promise (resolve, reject)->
            User.id(self.id).then (user)->
                self.profile = user.profile
                resolve self

module.exports = Player
