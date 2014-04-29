'use strict'

###
Socket.io configuration
###
module.exports = (io) ->
    require('../context').set('io', io)
    io.enable('browser client minification')  # send minified client
    io.enable('browser client etag')          # apply etag caching logic based on version number
    io.enable('browser client gzip')          # gzip the file
    io.set('log level', 1)                    # reduce logging
