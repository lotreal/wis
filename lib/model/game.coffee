'use strict'
uuid = require('node-uuid').v4
Promise = require('bluebird')
_ = require('lodash')
model = require('./index')

module.exports = (client)->
    players = []

    remove = (io)->
        _.remove(players, (p)->p.uid == io.uid)

    add = (io)->
        _.remove(players, (p)->p.uid == io.uid)
        players.push(io)

    return {
        add: add
        remove: remove
        status: ()->players
    }
