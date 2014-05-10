'use strict'

postal = require('postal')

Context = require('./context')
Player = require('./wis/player')
Fmt = require('./wis/sn')
game = require('./wis/gamefsm')
connect = require('./wis/connection')

# 建立游戏房间
testgame = game.getInstance('1ntlvb7r')
testgame.handle('initialized')

module.exports = (socket) ->
    connect.connect(socket)

    channel = postal.channel("wis.#{connect.findRoom(socket.id)}")

    socket.on 'wis:ready', ->
        channel.publish topic: 'ready', data:socket

    socket.on 'wis:speak', (msg)->
        channel.publish topic:'speak', data:{from:socket, message:msg}

    socket.on 'wis:start', ()->
        channel.publish topic: 'start'




    setupGame = (conn, socket)->
        # sessionId = socket.handshake.sessionID
        uid = connect.findUser(socket.id)

        socket.on 'game:debug', ()->
            # game.debug()



        socket.on 'game:vote', (target, fn)->
            channel.publish topic:'vote', data:{
                from:socket, target:target, callback:fn
            }

        return

    return
