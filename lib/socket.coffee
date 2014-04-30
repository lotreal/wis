'use strict'
_ = require('lodash')
Model = require('./model')
context = require('./context')

module.exports = (io, socket) ->
    # console.log IO: io
    # console.log socket: socket

    sid = socket.handshake.sessionID
    uid = socket.handshake.uid
    rid = '1ntlvb7r' # room id

    game = context.one "game:#{rid}", ()->
        game = require('./wis/game')(rid, io)
        game.init()

    player = Model.player.one(uid: uid, socketID: socket.id, io: io)
    game.addPlayer(player)

    # GM = require('./wis/gm').one(rid)

    # player = Model.player.one(uid: uid, socketID: socket.id, io: io)
    # GM.add(player)

    socket.on 'start:game', ()->
        game.go()

    socket.on 'game:speak', _.wrap socket, (socket, msg)->
        game.speak(socket, msg)

    return
