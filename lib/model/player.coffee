'use strict'

module.exports = (client)->
    user = require('./user')(client)

    class Player
        constructor: (options) ->
            @id = options.id
            @socket = options.socket

    return {
        get: (options)->new Player(options)
    }
