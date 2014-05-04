'use strict'
config = require('../config/config')
context = require('../context')
Model = require('../model')
User = Model.user
Team = require('./team')
io = context.get('io')
Promise = require('bluebird')
_ = require('lodash')
Fmt = require('./sn')
Stately = require('stately.js')
word = require('./word')
Logger = require('./store')
postal = require('postal')

module.exports = (rid, io)->
    countdown = (team, evt, count, message, done)->
        fn = ->
            team.broadcast 'all', evt, {count: count--, message: message}

            if (count > 0)
                setTimeout(fn, 1000)
            else
                setTimeout(done, 1000)
        return fn()

    startGame = (team, game)->
        done = ->
            team.beforePlay()
            words = if config.env == 'development' then ['CIVIL','SPY'] else word()
            team.broadcast 'civil', 'game:deal', word: words[0]
            team.broadcast 'spy', 'game:deal', word: words[1]
            game.word = civil:words[0], spy:words[1]
            game.setMachineState(game.PLAY)

        countdown(team, 'game:start:count', 2, '尚书大人正在出题(%d)', done)


    game = Stately.machine({
        READY:
            init: ->
                @team = context.one('team:'+rid, ()->new Team(rid, io))
                updatePlayer = (team)->
                    list = (p.profile.slogan for p in team.getMember())
                    team.broadcast 'all', 'game:player:update', Fmt.list(list)

                postal.subscribe(
                    channel  : 'game'
                    topic    : "member.change"
                    callback : (team, envelope)->
                        updatePlayer(team)
                )
                @logger = new Logger(@team)

                @round = 0
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
                @team.broadcast 'all', 'game:play:begin', ++@round
                @PLAY

            out: ->@READY

            speak: (from, msg)->
                @logger.log(@round, from, msg)
                @team.broadcast 'all', 'game:speak', Fmt.list(@logger.show(@round))

                # if all player speaked
                if @logger.fullpage(@round)
                    @team.broadcast 'all', 'game:vote:begin'
                    @logger.prepareVote()
                    return @VOTE
                else
                    return @PLAY

        VOTE:
            out: ->@READY

            vote: (from, target, fn)->
                unless @logger.isVoted(from)
                    fn("您已投票给 #{target+1} 号，等其他人投票后显示投票结果。")
                    @logger.vote(@round, from, target)

                if @logger.completeVote()
                    console.log round: @round
                    voteResult = @logger.getVoteResult(@team, @round)
                    @team.broadcast 'all', 'game:vote:result', Fmt.list(voteResult.list)
                    gameResult = @logger.getGameResult(@team, @)
                    console.log getGameResult: gameResult
                    if gameResult.gameover
                        @team.broadcast 'all', 'game:over', Fmt.list(gameResult.list)
                        return @READY

                    self = @
                    done = ->self.setMachineState(self.PLAY)
                    countdown(@team, 'game:start:count', 9, voteResult.title, done)

                    return @VOTE
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
