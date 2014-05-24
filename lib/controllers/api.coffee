"use strict"

_ = require('lodash')
postal = require('postal')
async = require('async')

passport = require('../passport')
Player = require('../wis/player')
Fmt = require('../wis/sn')


exports.getRoom = (req, res) ->
    rid = req.body.rid
    uid = req.session.passport.user
    async.waterfall [
        (callback)->
            player = new Player(uid)
            player.getProfile callback
        (profile, callback)->
            data =
                uid: uid
                room:
                    name: '康熙字典'
                    team: Fmt.team()
                profile: profile
            return callback(null, data)
        (data, callback)->
            channel = postal.channel("wis.#{rid}")
            channel.publish topic: 'reflash', data:{
                uid: uid
                callback: (snapshoot)->
                    callback(null,  _.merge(data, snapshoot))
            }
        (data)->
            res.json [null, data]
    ]
