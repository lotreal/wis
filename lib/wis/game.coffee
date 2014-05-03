'use strict'
context = require('../context')
Model = require('../model')
User = Model.user
Team = require('./team')
io = context.get('io')
Promise = require('bluebird')
_ = require('lodash')
sn = require('./sn')
Stately = require('stately.js')
word = require('./word')
MessageStore = require('./store').MessageStore

module.exports = (rid, io)->
    countdown = (team, evt, count, message, done)->
        fn = ->
            team.broadcast evt, {count: count--, message: message}

            if (count > 0)
                setTimeout(fn, 1000)
            else
                setTimeout(done, 1000)
        return fn()

    updatePlayer = (team)->
        list = (sn.cnNum(i+1) + '、' + p.profile.slogan for p,i in team.players)
        team.broadcast 'game:player:update', list

    startGame = (team, game)->
        done = ->
            words = word()
            team.broadcast 'game:deal', word: words[0]
            game.setMachineState(game.PLAY)

        countdown(team, 'game:start:count', 2, '服务器正在出题(%d)', done)


    game = Stately.machine({
        READY:
            init: ->
                @team = context.one('team:'+rid, ()->new Team(rid, io))
                @team.on 'update', updatePlayer
                @logger = new MessageStore(@team)

                @round = 1
                @READY

            debug: ->
                @logger.prepareVote()
                @VOTE

            in: (player)->
                @team.add player
                @READY

            out: (player)->
                @team.remove player
                @READY

            go: ->
                startGame(@team, @)
                @INIT

        INIT:
            out: ->@READY

        PLAY:
            init: ->
                @team.broadcast 'game:play:begin', @round++
                @PLAY

            out: ->@READY

            speak: (from, msg)->
                @logger.log(@round, from, msg)
                @team.broadcast 'game:speak', @logger.show(@round)

                # if all player speaked
                if @logger.fullpage(@round)
                    @team.broadcast 'game:vote:begin'
                    @logger.prepareVote()
                    return @VOTE
                else
                    return @PLAY

        VOTE:
            out: ->@READY

            vote: (from, target)->
                @logger.vote(@round, from, target)
                if @logger.completeVote()
                    @team.broadcast 'game:vote:result', @logger.currentVote.result()
                    return @PLAY
                else
                    return @VOTE

        OVER:
            restart: ->
                console.log restart: true
                @START
    }).bind((event, oldState, newState)->
        game.init() if oldState != newState
        console.log "#{oldState}.#{event}() => #{newState}"
        return
    )
    game.init()
    # game.onPLAY = (event, oldState, newState)->
    #     game.init() if oldState != newState

    # game.addPlayer('lot').addPlayer('nine').go().init().play().vote().play().vote().restart()
    return game
