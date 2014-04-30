'use strict'
context = require('../context')
Model = require('../model')
io = context.get('io')
Promise = require('bluebird')
_ = require('lodash')
sn = require('./sn')
Stately = require('stately.js')

module.exports = (rid, io)->

    countdown = (count, message, done)->
        fn = ->
            io.sockets.in(rid).emit 'count',
                {count:count--, message:message}
            if (count > 0)
                console.log count
                setTimeout(fn, 1000)
            else
                setTimeout(done, 1000)
        return fn()

    onTeamChange = (players)->
        Promise.all((Model.user.id(p.id) for p in players)).then (fills)->
            p.profile = fills[i].profile for p, i in players

            list = (sn.cnNum(i+1) + '、' + p.profile.slogan for p,i in players)
            io.sockets.in(rid).emit 'room:join', list
            console.log list


    game = Stately.machine({
        READY:
            init: ->
                console.log init: 'game'

                @id_team_all   = rid
                @id_team_spy   = "#{rid}:spy"
                @id_team_civil = "#{rid}:civil"

                @teams = {}
                @team = Model.team.one(@id_team_all)

                @team.on 'update', _.bind(onTeamChange, @)
                return @READY

            addPlayer: (player)->
                @team.add(player)
                return @READY

            go: ->
                self = this
                countdown(6, '服务器正在出题(%d)', ->
                    console.log 'start:game'
                    self.setMachineState(self.START)
                    self.START.init()
                    )
                @WAIT

        WAIT:
            quit: ->@READY

        START:
            addPlayer: ->@READY
            speak: (from, msg)->
                idx = @team.index(socketID: from.id)
                io.sockets.in(rid).emit 'game:speak', idx + msg
                @PLAY

            init: ->
                console.log send: 'words'
                @PLAY
        PLAY:
            addPlayer: ->@READY
            play: ->
                @round = if @round == undefined then 1 else ++@round
                console.log round:@round
                @VOTE
        VOTE:
            vote: ->
                console.log vote:@round
                if @round == 2
                    console.log result: true
                    return @OVER
                else
                    return @PLAY
        OVER:
            restart: ->
                console.log restart: true
                @START
    }).bind((event, oldState, newState)->
        transition = oldState + ' => ' + newState
        console.log transition
        return
    )

    # game.addPlayer('lot').addPlayer('nine').go().init().play().vote().play().vote().restart()
    return game
