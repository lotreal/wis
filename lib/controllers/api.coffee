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
        (done)->
            player = new Player(uid)
            player.fillout().then (filled)->
                data =
                    room:
                        name: '康熙字典'
                        team: Fmt.team()
                    profile: filled
                done(null, data)
        (data, done)->
            channel = postal.channel("wis.#{rid}")
            channel.publish topic: 'reflash', data:{
                uid: uid
                callback: (snapshoot)->
                    done(null,  _.merge(data, snapshoot))
            }
        (data)->
            res.json [null, data]
    ]
