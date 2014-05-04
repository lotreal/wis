'use strict'

_ = require('lodash')
util = require('../util')
postal = require('postal')

# viewer, player, spy, civil, blank, leave
module.exports = (->
    class Team
        constructor: (@id, @io) ->
            @group = {}
            @users = []

        member: ->@users
        length: ->@users.length
        index: (where)->_.findIndex(@users, where)

        beforePlay: ->
            sliced = util.sliceRnd(@users, 1)
            @group.spy = sliced[0]
            @group.civil = sliced[1]
            @group.player = _.clone @users
            @group.leaver = []
            return

        send: (target, event, data)->
            target = @group[target]
            p.getSocket().emit(event, data) for p in target
            return

        broadcast: (event, data)->
            @io.sockets.in(@id).emit event, data


        add: (player)->
            _.remove(@users, (p)->p.id == player.id) if @users
            @users.push(player)
            player.getSocket().join(@id)
            console.log in: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emitMemberChange()

        remove: (player)->
            _.remove(@users, (p)->p.id == player.id)
            player.getSocket().leave(@id)
            console.log out: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emitMemberChange()

        batchAdd: (users)->
            @add(p) for p in users

        emitMemberChange: ->
            postal.publish(
                channel : "game"
                topic   : "member.change",
                data    : @
            )

    return Team
)()
