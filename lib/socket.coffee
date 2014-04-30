'use strict'
_ = require('lodash')

module.exports = (io, socket) ->
    console.log IO: io
    console.log socket: socket

    sid = socket.handshake.sessionID
    uid = socket.handshake.uid
    rid = '1ntlvb7r' # room id

    me = id:uid, socket:socket.id
    GM = require('./wis/gm').one(rid)

    GM.add(me)

    socket.on 'start:game', ()->
        GM.countdown(6, '服务器正在出题(%d)', ->GM.startGame())

    socket.on 'game:speak', _.wrap socket, (socket, msg)->
            GM.speak(socket, msg)

    return
