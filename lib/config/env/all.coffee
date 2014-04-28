'use strict'
path = require('path')
rootPath = path.normalize(__dirname + '/../../..')
redis = require('redis')

module.exports =
    root: rootPath
    port: process.env.PORT or 3000
    redis: redis.createClient()
