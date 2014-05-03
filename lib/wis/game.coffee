'use strict'
context = require('../context')
Model = require('../model')
Team = require('./team')
io = context.get('io')
Promise = require('bluebird')
_ = require('lodash')
sn = require('./sn')
Stately = require('stately.js')
word = require('./word')
MessageStore = require('./store').MessageStore

module.exports = (rid, io)->
    round = 1

    id_team_spy   = "#{rid}:spy"
    id_team_civil = "#{rid}:civil"

    team = context.one('team:'+rid, ()->new Team(rid))

    room =
        team: sn.cnTeamname()

    onTeamChange = (players)->
        Promise.all((Model.user.id(p.id) for p in players)).then (fills)->
            p.profile = fills[i].profile for p, i in players

            list = (sn.cnNum(i+1) + '、' + p.profile.slogan for p,i in players)
            broadcast 'game:player:update', {players: list, teamname: room.team}
            console.log list

    team.on 'update', onTeamChange

    logger = new MessageStore(team)

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
            round = 1
            broadcast 'game:deal', {word: words[0], round: round}
            game.setMachineState(game.PLAY)

        countdown('game:start:count', 2, '服务器正在出题(%d)', done)


    game = Stately.machine({
        READY:
            debug: ->
                logger.prepareVote()
                @VOTE

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
            init: ->
                broadcast 'game:play:begin', round++
                @PLAY

            out: ->@READY

            speak: (from, msg)->
                logger.log(round, from, msg)
                broadcast 'game:speak', logger.show(round)

                # if all player speaked
                if logger.fullpage(round)
                    broadcast 'game:vote:begin'
                    logger.prepareVote()
                    return @VOTE
                else
                    return @PLAY

        VOTE:
            out: ->@READY

            vote: (from, target)->
                logger.vote(round, from, target)
                if logger.completeVote()
                    broadcast 'game:vote:result', logger.currentVote.result()
                    return @PLAY
                else
                    return @VOTE

        OVER:
            restart: ->
                console.log restart: true
                @START
    }).bind((event, oldState, newState)->
        console.log "#{oldState}.#{event}() => #{newState}"
        return
    )

    game.onPLAY = (event, oldState, newState)->
        game.init() if oldState != newState

    # game.addPlayer('lot').addPlayer('nine').go().init().play().vote().play().vote().restart()
    return game
