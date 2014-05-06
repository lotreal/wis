'use strict'
_ = require('lodash')
Context = require('./context')

Player = require('./wis/player')

Fmt = require('./wis/sn')
postal = require('postal')

module.exports = (io, socket) ->
    roomId = socket.handshake.query.rid
    room = Context.one "room:#{roomId}", ->
        return {
            name: '康熙字典'
            team: Fmt.teamname()
        }

    FSM = Context.one "gamefsm:#{roomId}", ()->
        require('./wis/gamefsm')(roomId, io)

    channel = postal.channel('wis')

    socket.on 'game:create', (opt, fn)->
        fn(room)
        setupGame(roomId, io, socket)

    setupGame = (roomId, io, socket)->
        sid = socket.handshake.sessionID
        uid = socket.handshake.uid

        channel.publish topic: 'initialized'

        player = new Player(uid: uid, socketID: socket.id, io: io)
        player.fillout().then(->
            channel.publish topic:'in', data:player
        )

        socket.on 'game:debug', ()->
            # game.debug()

        socket.on 'game:start', ()->
            channel.publish topic: 'go'

        socket.on 'game:speak', _.wrap socket, (socket, msg)->
            channel.publish topic:'speak', data:{from:socket, message:msg}

        socket.on 'game:vote', _.wrap socket, (socket, target, fn)->
            channel.publish topic:'vote', data:{
                from:socket, target:target, callback:fn
            }

        socket.on 'disconnect', ()->
            channel.publish topic:'out', data:player

        return

    return
