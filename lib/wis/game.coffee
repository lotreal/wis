'use strict'
context = require('../context')
Model = require('../model')
io = context.get('io')
Promise = require('bluebird')
_ = require('lodash')
sn = require('./sn')
Stately = require('stately.js')
word = require('./word')

module.exports = (rid, io)->
    round = 1
    id_team_all   = rid
    id_team_spy   = "#{rid}:spy"
    id_team_civil = "#{rid}:civil"
    team = Model.team.one(id_team_all)

    roomSetting =
        teamname: sn.cnTeamname()

    onTeamChange = (players)->
        Promise.all((Model.user.id(p.id) for p in players)).then (fills)->
            p.profile = fills[i].profile for p, i in players

            list = (sn.cnNum(i+1) + '、' + p.profile.slogan for p,i in players)
            broadcast 'game:player:update', {players: list, teamname: roomSetting.teamname}
            console.log list

    team.on 'update', onTeamChange

    class MessageStore
        constructor: (@team) ->
            @logs = {}
            @full = {}

        log: (page, from, message)->
            page = "page-#{page}"
            unless @logs[page]
                @logs[page] = {}
            @logs[page][from.id] = message
            return

        vote: (round, from, target)->

        show: (page, i)->
            logs = @logs["page-#{page}"]
            myturn = true

            d = (player, i)->
                message = logs[player.socketID]
                if message
                    if myturn
                        result = message
                    else
                        result = '**前面人发言后显示您的发言**'
                else
                    myturn = false
                    result = ''
                "#{sn.cnNum(i+1)}、#{result}"
            messages = (d(player, i) for player, i in @team.members())
            @full["page-#{page}"] = myturn
            return messages

        fullpage: (page)->
            @full["page-#{page}"]

    messageStore = new MessageStore(team)

    broadcast = (event, data, target = 'team')->
        io.sockets.in(rid).emit event, data

    countdown = (evt, count, message, done)->
        fn = ->
            broadcast evt, {count: count--, message: message}

            if (count > 0)
                setTimeout(fn, 1000)
            else
                setTimeout(done, 1000)
        return fn()


    prepareGame = ->
        new Promise (resolve, reject)->
            console.log assign: 'role'
            console.log random: 'words'
            resolve word: 'spy'

    startGame = (game)->
        done = ->
            words = word()

            broadcast 'game:deal', {word: words[0], round: round}
            game.setMachineState(game.PLAY)

        countdown('game:start:count', 6, '服务器正在出题(%d)', done)


    game = Stately.machine({
        READY:
            in: (player)->
                team.add player
                @READY

            out: (player)->
                team.remove player
                @READY

            go: ->
                startGame(@)
                @INIT

        INIT:
            out: ->@READY

        PLAY:
            out: ->@READY

            play: ->
                round++
                console.log round: round
                @VOTE

            speak: (from, msg)->
                messageStore.log(round, from, msg)
                broadcast 'game:speak', messageStore.show(round)
                console.log full: messageStore.fullpage(round)
                return if messageStore.fullpage(round) then @VOTE else @PLAY

        VOTE:
            out: ->@READY

            vote: (from, target)->
                console.log vote:round
                messageStore.vote(round, from, target)
                if round == 2
                    console.log result: true
                    return @OVER
                else
                    return @PLAY
        OVER:
            restart: ->
                console.log restart: true
                @START
    }).bind((event, oldState, newState)->
        console.log "#{oldState}.#{event}() => #{newState}"
        return
    )

    # game.addPlayer('lot').addPlayer('nine').go().init().play().vote().play().vote().restart()
    return game
