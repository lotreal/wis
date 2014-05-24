'use strict'

_ = require('lodash')
postal = require('postal')

connectionPool = {}
rooms = {}

flashPoll = {}
flashTimeout = {}

channel = postal.channel('connection')

id = (uid, rid)->"#{uid}@#{rid}"

# 用户是否已连入房间
inRoom = (uid, rid)->
    rids = _.map(findSockets(uid), (sid)->rooms[sid])
    return _.contains(rids, rid)

# 得到用户的所有连接
findSockets = (uid)->
    sockets = []
    for k, v of connectionPool
        sockets.push(k) if v == uid
    # console.log uid:uid, sockets:sockets
    return sockets

# sockets -> uid
findUser = (socket)->
    return connectionPool[socket.id] || null

# sockets -> roomId
findRoom = (socketId)->
    return rooms[socketId] || null

disconnect = (socket)->
    sid = socket.id
    uid = connectionPool[sid]
    rid = rooms[sid]

    publish = (uid, rid, sid)->
        delete flashTimeout[id(uid, rid)]

        unless inRoom(uid, rid)
            channel.publish "out.#{rid}", uid
            console.log out: "#{uid}@#{rid}<<<#{sid}>>>"

    # 如果 3 秒内重连，则不发送离开事件
    flashTimeout[id(uid, rid)] = setTimeout(
        _.bind(publish, this, uid, rid, sid), 3000)

    console.log disconnect: "#{uid}@#{rid}<<<#{sid}>>>"
    delete connectionPool[sid]
    delete rooms[sid]

connect = (socket)->
    sid = socket.id
    uid = socket.handshake.uid
    rid = socket.handshake.query.rid
    console.log connect: "#{uid}@#{rid}<<<#{sid}>>>"

    timeout = flashTimeout[id(uid, rid)]
    if timeout
        clearTimeout timeout
        console.log flash: "#{uid}@#{rid}<<<#{sid}>>>"
        # channel.publish "flash.#{rid}", uid
    else
        unless inRoom(uid, rid)
            channel.publish "in.#{rid}", uid
            console.log in: "#{uid}@#{rid}<<<#{sid}>>>"

    connectionPool[sid] = uid
    rooms[sid] = rid

    socket.on 'disconnect', -> disconnect(socket)
    return {
        uid: uid
        socketId: sid
        roomId: rid
    }

exports.connect = connect
exports.disconnect = disconnect

exports.findSockets = findSockets
exports.findUser = findUser
exports.findRoom = findRoom
