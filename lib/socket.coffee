'use strict'
_ = require('lodash')
Context = require('./context')

Player = require('./wis/player')
gameFsm = require('./wis/game')
Fmt = require('./wis/sn')

module.exports = (io, socket) ->
    roomId = socket.handshake.query.rid
    room = Context.one "room:#{roomId}", ->
        return {
            name: '现代汉语词典'
            team: Fmt.teamname()
        }

    socket.on 'game:create', (opt, fn)->
        fn(room)
        setupGame(roomId, io, socket)

    setupGame = (roomId, io, socket)->
        sid = socket.handshake.sessionID
        uid = socket.handshake.uid

        game = Context.one "game:#{roomId}", ()->gameFsm(roomId, io)

        player = new Player(uid: uid, socketID: socket.id, io: io)
        player.fillout().then(->game.in(player))

        socket.on 'game:debug', ()->
            # game.debug()

        socket.on 'game:start', ()->
            game.go()

        socket.on 'game:speak', _.wrap socket, (socket, msg)->
            game.speak(socket, msg)

        socket.on 'game:vote', _.wrap socket, (socket, target)->
            game.vote(socket, target)

        socket.on 'disconnect', ()->
            game.out(player)

        return

    return
