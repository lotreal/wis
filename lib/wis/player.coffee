'use strict'

Promise = require('bluebird')
User = require('../model').user

module.exports = (->
    class Player
        constructor: (options) ->
            @id = options.uid
            @socketID = options.socketID
            @io = options.io
            @state = 'OK'

        getSocket: ->
            @io.sockets.sockets[@socketID]

        fillout: ->
            self = @
            return new Promise (resolve, reject)->
                User.id(self.id).then (user)->
                    self.profile = user.profile
                    resolve self

    return Player
)()
