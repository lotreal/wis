'use strict'
_ = require('lodash')
Context = require('./context')

Player = require('./model').player
Game = require('./wis/game')

module.exports = (io, socket) ->
    sid = socket.handshake.sessionID
    uid = socket.handshake.uid
    rid = '1ntlvb7r' # room id

    game = Context.one "game:#{rid}", ()->Game(rid, io)
    player = Player.one(uid: uid, socketID: socket.id, io: io)

    game.in(player)

    socket.on 'game:start', ()->
        game.go()
        game.init()

    socket.on 'game:speak', _.wrap socket, (socket, msg)->
        game.speak(socket, msg)

    socket.on 'disconnect', ()->
        game.out(player)

    return
