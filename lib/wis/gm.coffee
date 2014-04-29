'use strict'
context = require('../context')
Model = require('../model')
io = context.get('io')
Promise = require('bluebird')

module.exports = (()->

    class GM
        constructor: (@id)->
            @id_team_spy   = "#{id}:spy"
            @id_team_civil = "#{id}:civil"
            @teams = {}
            @teams.all = Model.team.one(id)

        add: (player)->
            player = Model.player.one(player)
            @teams.all.add(player)
            socket = io.sockets.sockets[player.socket]
            socket.join(@teams.all.id)
            console.log('A socket with UID ' + player.id + ' connected!')
            @onTeamChange()
            self = @
            socket.on 'disconnect', ()->self.remove(player)

        remove: (player)->
            player = Model.player.one(player)
            @teams.all.remove(player)
            socket = io.sockets.sockets[player.socket]
            socket.leave(@teams.all.id)
            console.log('A socket with UID ' + player.id + ' disconnected!')
            @onTeamChange()

        onTeamChange: ()->
            team = @teams.all
            players = team.members()
            console.log players
            Promise.all((Model.user.id(p.id) for p in players)).then (fills)->
                p.profile = fills[i].profile for p, i in players
                io.sockets.in(team.id).emit 'room:join', players

        countdown: (count, message, done)->
            team = @teams.all
            fn = ->
                io.sockets.in(team.id).emit 'count',
                    {count:count--, message:message}
                if (count > 0)
                    console.log count
                    setTimeout(fn, 1000)
                else
                    setTimeout(done, 1000)
            return fn()

        startGame: ()->
            @setPlayerRole()

            words =
                spy: '三明治'
                civil: '肉夹馍'

            for player in @spy.members()
                io.sockets.sockets[player.socket].emit 'start:game', words.spy

            for player in @civil.members()
                io.sockets.sockets[player.socket].emit 'start:game', words.civil

            return


        setPlayerRole: ->
            @spy = Model.team.one("#{@id}:spy")
            @civil = Model.team.one("#{@id}:civil")

            all = @teams.all.members()
            @spy.add all[0]
            @civil.add all[1]

            console.log spy: @spy.members()
            console.log civil: @civil.members()
            return

    return {
        one: (id)->
            context.one('gm:'+id, ()->new GM(id))
    }
)()
