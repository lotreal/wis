'use strict'

postal = require('postal')

conn = require('../wis/connection')

###
Socket.io configuration
###
module.exports = (io) ->
    io.enable('browser client minification')  # send minified client
    io.enable('browser client etag')          # apply etag caching logic based on version number
    io.enable('browser client gzip')          # gzip the file
    io.set('log level', 1)                    # reduce logging

    postal.subscribe(
        channel  : 'connection'
        topic    : 'broadcast'
        callback : (data, envelop)->
            for user in data.target
                for sid in conn.findSockets(user.getId())
                    socket = io.sockets.sockets[sid] if sid
                    socket.emit(data.event, data.data) if socket
            return
    )

    return
