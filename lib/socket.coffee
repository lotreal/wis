'use strict'
_ = require('lodash')
Context = require('./context')

Player = require('./model').player
Game = require('./wis/game')

module.exports = (io, socket) ->
    sid = socket.handshake.sessionID
    uid = socket.handshake.uid

    roomId = socket.handshake.query.rid

    game = Context.one "game:#{roomId}", ()->Game(roomId, io)
    player = Player.one(uid: uid, socketID: socket.id, io: io)

    game.in(player)

    socket.on 'game:start', ()->
        game.go()

    socket.on 'game:speak', _.wrap socket, (socket, msg)->
        game.speak(socket, msg)

    socket.on 'game:vote', _.wrap socket, (socket, target)->
        game.vote(socket, target)

    socket.on 'disconnect', ()->
        game.out(player)

    return
