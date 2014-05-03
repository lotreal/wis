'use strict'

_ = require('lodash')
events = require('events')

module.exports = (->
    class Team extends events.EventEmitter
        constructor: (@id, @io) ->
            @players = []

        remove: (player)->
            _.remove(@players, (p)->p.id == player.id)
            player.getSocket().leave(@id)
            console.log out: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emit 'update', @

        add: (player)->
            _.remove(@players, (p)->p.id == player.id) if @players
            @players.push(player)
            player.getSocket().join(@id)
            console.log in: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emit 'update', @

        index: (where)->
            _.findIndex(@players, where)

        members: ()->@players

        length: ()->@players.length

        broadcast: (event, data)->
            @io.sockets.in(@id).emit event, data

    return Team
)()
