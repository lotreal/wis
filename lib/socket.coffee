'use strict'

module.exports = (socket) ->
    sid = socket.handshake.sessionID
    uid = socket.handshake.uid
    rid = '1ntlvb7r' # room id

    me = id:uid, socket:socket.id
    GM = require('./wis/gm').one(rid)

    GM.add(me)



    socket.on 'start:game', (a, b, c)->
        GM.countdown(6)

    countdown = (count, message, done)->

    countdown(6, '服务器正在出题(%d)', ()->
        socket.emit 'start:game'
        )

    # io.sockets.sockets[data.to].emit
    # send(player, channel, content)
    startGame = ()->
        # all = team.status()
        role =
            spy: 1
            blank: 1
            civil: '*'
        return
    return
