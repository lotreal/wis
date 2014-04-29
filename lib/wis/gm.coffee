'use strict'
context = require('../context')
Model = require('../model')
io = context.get('io')
Promise = require('bluebird')

module.exports = (()->

    class GM
        constructor: (@id)->
            @team = Model.team.one(id)

        add: (player)->
            player = Model.player.one(player)
            @team.add(player)
            socket = io.sockets.sockets[player.socket]
            socket.join(@team.id)
            console.log('A socket with UID ' + player.id + ' connected!')
            @onTeamChange()
            self = @
            socket.on 'disconnect', ()->self.remove(player)

        remove: (player)->
            player = Model.player.one(player)
            @team.remove(player)
            socket = io.sockets.sockets[player.socket]
            socket.leave(@team.id)
            console.log('A socket with UID ' + player.id + ' disconnected!')
            @onTeamChange()

        onTeamChange: ()->
            team = @team
            players = team.all()
            Promise.all((Model.user.id(p.id) for p in players)).then (fills)->
                p.profile = fills[i].profile for p, i in players
                io.sockets.in(team.id).emit 'room:join', players

        countdown: (count, message, done)->
            team = @team
            fn = ->
                io.sockets.in(team.id).emit 'count', count--
                if (count > 0)
                    console.log count
                    setTimeout(fn, 1000)
                else
                    console.log 'done'
            return fn()

    return {
        one: (id)->
            context.one('gm:'+id, ()->new GM(id))
    }
)()
