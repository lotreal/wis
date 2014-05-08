"use strict"

_ = require('lodash')
postal = require('postal')

passport = require('../passport')
Player = require('../wis/player')
Fmt = require('../wis/sn')


exports.getRoom = (req, res) ->
    rid = req.body.rid
    token = req.session.token
    passport.verify token, (err, decoded)->
        return res.json [err] if err
        player = new Player(decoded.uid)
        player.fillout().then ->
            data =
                room:
                    name: '康熙字典'
                    team: Fmt.teamname()
                profile: player
            channel = postal.channel("wis.#{rid}")
            channel.publish topic: 'reflash', data:(snapshoot)->
                data = _.merge(data, snapshoot)
                res.json [null, data]
    return
