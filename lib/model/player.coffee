'use strict'

module.exports = (client)->
    user = require('./user')(client)

    class Player
        constructor: (options) ->
            @id = options.uid
            @socketID = options.socketID
            @io = options.io

        socket: ->
            @io.sockets.sockets[@socketID]

    return {
        one: (options)->new Player(options)
    }
