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
            unless _.find(@member, (p)->p.getId() == player.getId())
                @member.push(player)
                @emitMemberChange()

        remove: (player)->
            _.remove(@member, (p)->p.getId() == player.getId())
            @emitMemberChange()

        emitMemberChange: ->
            postal.publish(
                channel : "wis"
                topic   : "#{@id}.member.change",
                data    : @
            )

    return Team
)()
