'use strict'
uuid = require('node-uuid').v4
Promise = require('bluebird')
_ = require('lodash')

module.exports = (client)->
    player = require('./player')(client)

    players = []

    remove = (io)->
        _.remove(players, (p)->p.id == io.id)

    add = (io)->
        _.remove(players, (p)->p.id == io.id)
        players.push(player.get(io))

    return {
        add: add
        remove: remove
        status: ()->players
    }
