'use strict'

_ = require('lodash')
machina = require('machina')()
postal = require('postal')
require('machina.postal')(machina, postal)

config = require('../config/config')
context = require('../context')
Model = require('../model')
User = Model.user
Team = require('./team')
io = context.get('io')
Promise = require('bluebird')
Fmt = require('./sn')
word = require('./word')
Logger = require('./store')

countdown = (team, evt, count, message, done)->
    fn = ->
        team.broadcast 'all', evt, {count: count--, message: message}

        if (count > 0)
            setTimeout(fn, 1000)
        else
            setTimeout(done, 1000)
    return fn()


module.exports = (rid, io)->
    game = new machina.Fsm(
        initialState: 'uninitialized'

        namespace: 'wis'

        states:
            uninitialized:
                initialized: ->
                    @round = 0
                    @team = context.one('team:'+rid, ()->new Team(rid, io))
                    @logger = new Logger(@team)

                    @emit 'Initialized', 1, 2, 3
                    console.log 'Initialized'
                    @transition 'ready'

                _onExit: ->
                    # console.log exit:@

            ready:
                _onEnter: ->
                    console.log 'enter ready'

                update: ->
                    list = (p.profile.slogan for p in @team.getMember())
                    @team.broadcast 'all', 'game:player:update', list

                in: (player)->
                    @team.add player
                    @.handle('update')

                out: (player)->
                    @team.remove player
                    @.handle('update')

                speak: (data)->
                    i = @team.index(socketID: data.from.id)
                    @team.broadcast 'all', 'game:chat', {index:i,message:data.message}

                go: ->
                    done = ->
                        @team.beforePlay()
                        words = if config.env == 'development' then ['CIVIL','SPY'] else word()
                        @team.broadcast 'civil', 'game:deal', word: words[0]
                        @team.broadcast 'spy', 'game:deal', word: words[1]
                        @word = civil:words[0], spy:words[1]
                        @.transition('play')

                    countdown(@team, 'game:start:count', 2,
                        '尚书大人正在出题(%d)', _.bind(done, @))

            play:
                _onEnter: ->
                    @team.broadcast 'all', 'game:play:begin', ++@round

                speak: (from, msg)->
                    @logger.log(@round, from, msg)
                    @team.broadcast 'all', 'game:speak', Fmt.list(@logger.show(@round))

                    # if all player speaked
                    if @logger.fullpage(@round)
                        @team.broadcast 'all', 'game:vote:begin'
                        @logger.prepareVote()
                        @.transition('vote')

            vote:
                vote: ->

    )

    return game
