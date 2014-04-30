'use strict'
context = require('../context')
Model = require('../model')
io = context.get('io')
Promise = require('bluebird')
_ = require('lodash')
sn = require('./sn')

module.exports = (()->
    GM_STATE_READY = 'ready'
    GM_STATE_GO    = 'go'

    class GM
        constructor: (@id)->
            @state = GM_STATE_READY
            @round = 1

            @id_team_all   = id
            @id_team_spy   = "#{id}:spy"
            @id_team_civil = "#{id}:civil"

            @teams = {}
            @teams.all = Model.team.one(@id_team_all)
            @teams.all.on 'update', _.bind(@onTeamChange, @)

        findIndex: (where)->
            _.findIndex(@teams.all.members(), where)

        add: (player)->
            @teams.all.add(player)

        onTeamChange: (players)->
            team = @teams.all
            # console.log players
            Promise.all((Model.user.id(p.id) for p in players)).then (fills)->
                p.profile = fills[i].profile for p, i in players

                list = (sn.cnNum(i+1) + '、' + p.profile.slogan for p,i in players)
                io.sockets.in(team.id).emit 'room:join', list


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
            @state = GM_STATE_GO

            @setPlayerRole()

            words =
                spy: '三明治'
                civil: '肉夹馍'

            for player in @teams.spy.members()
                io.sockets.sockets[player.socket].emit 'start:game', {word:words.spy, round: @round}

            for player in @teams.civil.members()
                io.sockets.sockets[player.socket].emit 'start:game', {word:words.civil, round: @round}

            return

        actionGo: ()->

        speak: (socket, msg)->
            idx = @findIndex(socket: socket.id)
            @broadcast('game:speak', idx + msg)


        broadcast: (event, data)->
            io.sockets.in(@id_team_all).emit event, data

        setPlayerRole: ->
            @teams.spy = Model.team.one(@id_team_spy)
            @teams.civil = Model.team.one(@id_team_civil)

            all = @teams.all.members()

            @teams.spy.add all[0]
            @teams.civil.add all[1]

            console.log spy: @teams.spy.members()
            console.log civil: @teams.civil.members()
            return

    return {
        one: (id)->
            context.one('gm:'+id, ()->new GM(id))
    }
)()
