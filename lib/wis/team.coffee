'use strict'

_ = require('lodash')
util = require('../util')
postal = require('postal')

# viewer, player, spy, civil, blank, leave
module.exports = (->
    class Team
        constructor: (@id) ->
            @group = {}
            @disconnected = {}
            @member = []

        getMember: ->@member
        getPlayer: ->@group.player
        getLeft:   ->@group.left
        getCivil:  ->@group.civil
        getSpy:    ->@group.spy
        getHit:    ->@group.hit

        beforePlay: ->
            sliced = util.sliceRnd(@member, 1)
            @group.spy    = sliced[0]
            @group.civil  = sliced[1]
            @group.player = _.clone @member
            @group.left   = _.clone @member
            @group.hit    = []
            @group.leaver = []
            return

        broadcast: (group, event, data)->
            target = if group == 'all' then @getMember() else @group[group]
            for p in @getMember()
                postal.publish(
                    channel : "wis"
                    topic   : "socket.io.emit",
                    data    :
                        target: target
                        event:  event
                        data:   data
                )
            return

        hit: (player)->
            _.pull(@group.left, player)
            @group.hit.push(player)

        getRole: (player)->
            return 'civil' if _.contains(@getCivil(), player)
            return 'spy' if _.contains(@getSpy(), player)
            return 'unknown'

        add: (player)->
            uid = player.getId()
            leave = @disconnected[uid]
            if leave
                clearTimeout(leave)
                p = _.find(@getMember(), (p)->p.getId() == uid)
                console.log reflash: "#{uid}<<<#{@id}>>>#{p.socketID}"
                delete @disconnected[uid]
            else
                _.remove(@member, (p)->p.id == player.id) if @member
                @member.push(player)
                console.log in: "#{player.id}<<<#{@id}>>>#{player.socketID}"
                @emitMemberChange()

        remove: (player)->
            _.remove(@member, (p)->p.id == player.id)
            console.log out: "#{player.id}<<<#{@id}>>>#{player.socketID}"
            @emitMemberChange()

        disconnect: (player)->
            uid = player.getId()

            fn = ->
                @remove(player)
                delete @disconnected[uid]

            # 如果 2 秒内重连，则只更换 socketId，不实际 remove
            @disconnected[uid] = setTimeout(_.bind(fn, this), 2000)
            return @disconnected[uid]


        batchAdd: (member)->
            @add(p) for p in member

        emitMemberChange: ->
            postal.publish(
                channel : "wis"
                topic   : "#{@id}.member.change",
                data    : @
            )

    return Team
)()
