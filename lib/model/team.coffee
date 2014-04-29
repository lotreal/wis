'use strict'
uuid = require('node-uuid').v4
Promise = require('bluebird')
_ = require('lodash')
context = require('../context')

module.exports = (client)->
    class Team
        constructor: (@id) ->
            @players = []

        remove: (player)->
            _.remove(@players, (p)->p.id == player.id)

        add: (player)->
            _.remove(@players, (p)->p.id == player.id) if @players
            @players.push(player)

        members: ()->@players

    return {
        one: (id)->
            context.one('team:'+id, ()->new Team(id))

    }
