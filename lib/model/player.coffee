'use strict'

module.exports = (client)->
    user = require('./user')(client)

    class Player
        constructor: (options) ->
            @id = options.id
            @io = options.io
            user.id(@id).bind(@)
                .then((user)->@profile=user.profile;return)

    return {
        get: (options)->new Player(options)
    }
