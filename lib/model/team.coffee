'use strict'
uuid = require('node-uuid').v4
Promise = require('bluebird')
_ = require('lodash')

module.exports = (client)->
    Player = require('./player')(client)
    cache = {}

    class Team
        constructor: (@id) ->
            @players = []

        remove: (player)->
            _.remove(@players, (p)->p.id == player.id)

        add: (player)->
            _.remove(@players, (p)->p.id == player.id)
            @players.push(Player.get(player))

        status: ()->@players

    return {
        get: (id)->
            obj = cache[id]
            unless obj
                obj = new Team(id)
                cache[id] = obj
            return obj
    }
