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
            console.log out: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emit 'update', @players

        add: (player)->
            _.remove(@players, (p)->p.id == player.id) if @players
            @players.push(player)
            player.socket().join(@id)
            console.log in: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emit 'update', @players

        index: (where)->
            _.findIndex(@players, where)

        members: ()->@players

        length: ()->@players.length

    return {
        one: (id)->
            context.one('team:'+id, ()->new Team(id))
    }
