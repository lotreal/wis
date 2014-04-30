'use strict'
_ = require('lodash')
context = require('../context')
events = require('events')

module.exports = (client)->
    class Team extends events.EventEmitter
        constructor: (@id) ->
            @players = []

        remove: (player)->
            _.remove(@players, (p)->p.id == player.id)
            player.socket().leave(@id)
            console.log removePlayer: player.id, from: @id
            @emit 'update', @players

        add: (player)->
            _.remove(@players, (p)->p.id == player.id) if @players
            @players.push(player)
            player.socket().join(@id)
            console.log addplayer: player.id, from: @id
            @emit 'update', @players
            player.socket().on 'disconnect', _.bind(@remove, this, player)

        members: ()->@players

    return {
        one: (id)->
            context.one('team:'+id, ()->new Team(id))
    }
