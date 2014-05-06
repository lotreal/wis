'use strict'

db = {}

disconnect = (socket)->
    console.log db: db
    delete db[socket.id]

connect = (socket)->
    sid = socket.id
    uid = socket.handshake.uid
    rid = socket.handshake.query.rid

    db[sid] = uid
    socket.on 'disconnect', -> disconnect(socket)
    return {
        uid: uid
        socketId: sid
        roomId: rid
    }

exports.connect = connect
exports.disconnect = disconnect

exports.getUid = (socketId)->
    return db[socketId] || null
