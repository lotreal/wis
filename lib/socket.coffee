'use strict'
_ = require('lodash')
Model = require('./model')

module.exports = (io, socket) ->
    # console.log IO: io
    # console.log socket: socket

    sid = socket.handshake.sessionID
    uid = socket.handshake.uid
    rid = '1ntlvb7r' # room id

    GM = require('./wis/gm').one(rid)

    player = Model.player.one(uid: uid, socketID: socket.id, io: io)
    GM.add(player)

    socket.on 'start:game', ()->
        GM.countdown(6, '服务器正在出题(%d)', ->GM.startGame())

    socket.on 'game:speak', _.wrap socket, (socket, msg)->
            GM.speak(socket, msg)

    return
