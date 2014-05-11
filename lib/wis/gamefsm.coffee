'use strict'

_ = require('lodash')
machina = require('machina')()
postal = require('postal')
require('machina.postal')(machina, postal)

config = require('../config/config')
context = require('../context')
Model = require('../model')
User = Model.user
Player = require('./player')
Team = require('./team')
Promise = require('bluebird')
Fmt = require('./sn')
word = require('./word')
Logger = require('./store')
conn = require('./connection')
util = require('../util')

countdown = (team, evt, count, message, done)->
    fn = ->
        team.broadcast 'all', evt, {count: count--, message: message}

        if (count > 0)
            setTimeout(fn, 1000)
        else
            setTimeout(done, 1000)
    return fn()


create = (rid)->
    game = new machina.Fsm(
        initialState: 'uninitialized'

        namespace: "wis.#{rid}"

        states:
            uninitialized:
                initialized: ->
                    @team = context.one('team:'+rid, ()->new Team(rid))

                    console.log 'Initialized'
                    @transition 'ready'

                _onExit: ->
                    # console.log exit:@

            ready:
                _onEnter: ->
                    @round = 0
                    @logger = new Logger(@team)
                    console.log 'enter ready'

                snapshot: (callback)->
                    players = @logger.loadWaitroom()
                    callback(null, players)

                update: ->
                    console.log team: @team.getMember()
                    players = @logger.loadWaitroom()
                    @team.broadcast 'all', 'wis:reflash', players

                ready: (from)->
                    uid = conn.findUser(from.id)
                    player = _.find(@team.getMember(), (p)->p.getId() == uid)
                    index = _.findIndex(@team.getMember, (p)->p.getId() == uid)
                    mod =
                        uid:uid
                        isReady:player.toggleReady()
                        isMaster:index == 0
                    @team.broadcast 'all', 'wis:usermod', mod

                in: (player)->
                    @team.add player
                    console.log addPlayer:player
                    @handle('update')

                out: (player)->
                    @team.remove player
                    console.log remove:player
                    @handle('update')

                speak: (data)->
                    console.log "#{data.from.id}: #{data.message}"
                    uid = conn.findUser(data.from.id)
                    i = _.findIndex(@team.getMember(), uid:uid)
                    player = @team.getMember()[i]
                    player.message = data.message

                    @team.broadcast 'all', 'wis:speak', {index:i,message:data.message,uid:uid}

                start: ->
                    @team.broadcast 'all', 'wis:start:forecast'
                    done = ->
                        @team.beforePlay()
                        words = if config.env == 'development' then ['CIVIL','SPY'] else word()
                        @team.broadcast 'civil', 'wis:start', word: words[0]
                        @team.broadcast 'spy', 'wis:start', word: words[1]
                        @word = civil:words[0], spy:words[1]
                        @transition('play')

                    countdown(@team, 'wis:start:countdown', 6,
                        '尚书大人正在出题(%d)', _.bind(done, @))

            play:
                _onEnter: ->
                    @team.broadcast 'all', 'wis:start:round', ++@round

                snapshot: (callback)->
                    # players = @logger.loadWaitroom()
                    callback(null, playsnapshot: 'todo')


                speak: (data)->
                    @logger.log(@round, data.from, data.message)
                    @team.broadcast 'all', 'wis:speak', Fmt.list(@logger.show(@round))

                    # if all player speaked
                    if @logger.fullpage(@round)
                        @team.broadcast 'all', 'game:vote:begin'
                        @logger.prepareVote()
                        @.transition('vote')

            vote:
                vote: (data)->
                    from = data.from
                    target = data.target
                    fn = data.callback

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
                            @.transition('ready')
                            return

                        self = @
                        done = ->self.transition('play')
                        countdown(@team, 'game:start:count', 9, voteResult.title, done)

    )

    postal.subscribe(
        channel : 'connection'
        topic   : "in.#{rid}"
        callback: (uid, envelope)->
            player = new Player(uid)
            player.fillout().then(->
                game.handle('in', player)
            )
    )

    postal.subscribe(
        channel : 'connection'
        topic   : "out.#{rid}"
        callback: (uid, envelope)->
            player = new Player(uid)
            game.handle('out', player)
    )

    postal.subscribe(
        channel : "wis.#{rid}"
        topic   : 'reflash'
        callback: (callback, envelope)->
            game.handle 'snapshot', (err, data)->
                data.state = game.state
                callback(data)
    )

    return game

exports.create = create
exports.getInstance = (rid)->
    return util.singletons("gamefsm:#{rid}", ->create(rid))
