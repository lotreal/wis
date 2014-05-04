'use strict'

_ = require('lodash')
Util = require('../util')
postal = require('postal')

# viewer, player, spy, civil, blank
module.exports = (->
    class Team
        constructor: (@id, @io) ->
            @players = []

        emitMemberChange: ->
            postal.publish(
                channel : "game"
                topic   : "member.change",
                data    : @
            )

        add: (player)->
            _.remove(@players, (p)->p.id == player.id) if @players
            @players.push(player)
            player.getSocket().join(@id)
            console.log in: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emitMemberChange()

        remove: (player)->
            _.remove(@players, (p)->p.id == player.id)
            player.getSocket().leave(@id)
            console.log out: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emitMemberChange()

        batchAdd: (players)->
            @add(p) for p in players

        index: (where)->
            _.findIndex(@players, where)

        member: ()->@players

        length: ()->@players.length

        broadcast: (event, data)->
            @io.sockets.in(@id).emit event, data

    return Team
)()
