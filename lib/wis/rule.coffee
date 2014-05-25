'use strict'

_ = require('lodash')
machina = require('machina')()
postal = require('postal')
require('machina.postal')(machina, postal)

config = require('../config/config')
context = require('../context')
Player = require('./player')
Team = require('./team')
Promise = require('bluebird')
Fmt = require('./sn')

GameMaster = require('./gm')
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

        record: (fsm, data)->
            method = @GM[@_currentAction]
            _.bind(method, @GM, data)() if method

        getPlayerFromSocket: (socket)->
            uid = conn.findUser(socket)
            player = _.find(@team.getMember(), (p)->p.getId() == uid)
            return player

        states:
            uninitialized:
                initialized: ->
                    @team = context.one('team:'+rid, ()->new Team(rid))
                    @GM = new GameMaster(@)

                    console.log 'Initialized'
                    @transition 'ready'

                _onExit: ->
                    # console.log exit:@

            ready:
                _onEnter: ->
                    @round = 0
                    console.log 'enter ready'

                snapshot: (uid, callback)->
                    players = @GM.loadWaitroom()
                    callback(null, players)

                update: ->
                    console.log team: @team.getMember()
                    players = @GM.loadWaitroom()
                    @team.broadcast 'all', 'wis:reflash', players

                ready: (from)->
                    uid = conn.findUser(from)
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
                    uid = conn.findUser(data.from)
                    i = _.findIndex(@team.getMember(), uid:uid)
                    player = @team.getMember()[i]
                    player.message = data.message

                    @team.broadcast 'all', 'wis:speak', {index:i,message:data.message,uid:uid}

                start: ->
                    @team.broadcast 'all', 'wis:start:forecast'

                    # 发牌
                    deal = (role)->
                        console.log role:@GM.getScene(role, @round)
                        @team.broadcast role, 'wis:start',
                            @GM.getScene(role, @round)

                    done = ->
                        @GM.start()
                        _.forEach @team.roles, _.bind(deal, @)
                        @transition('play')

                    countdown(@team, 'wis:start:countdown', 1,
                        '尚书大人正在出题(%d)', _.bind(done, @))

            play:
                _onEnter: ->
                    @team.broadcast 'all', 'wis:start:round', ++@round

                snapshot: (uid, callback)->
                    player = @team.find(uid)
                    role = @team.getRole(player)

                    data = @GM.getScene(role, @round)
                    callback(null, data)

                speak: (data)->
                    player = data.player = @getPlayerFromSocket(data.from)
                    scene = @record @, data

                    @team.broadcast 'all', 'wis:speak', scene

                    if !scene.next
                        @team.broadcast 'all', 'game:vote:begin'
                        @GM.prepareVote()
                        console.log 'vote'
                        # @transition('vote')

            vote:
                vote: (data)->
                    from = data.from
                    target = data.target
                    fn = data.callback

                    unless @GM.isVoted(from)
                        fn("您已投票给 #{target+1} 号，等其他人投票后显示投票结果。")
                        @GM.vote(@round, from, target)

                    if @GM.completeVote()
                        console.log round: @round
                        voteResult = @GM.getVoteResult(@team, @round)
                        @team.broadcast 'all', 'game:vote:result', Fmt.list(voteResult.list)
                        gameResult = @GM.getGameResult(@team, @)
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
            player.getProfile ->
                game.handle('in', player)
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
        callback: (data, envelope)->
            game.handle 'snapshot', data.uid, (err, res)->
                res.state = game.state
                data.callback(res)
    )

    # postal.subscribe(
    #     channel : "wis.#{rid}"
    #     topic   : '*'
    #     callback: (data, envelope)->
    #         console.log M:data, E:envelope, G:game
    # )

    return game

exports.create = create
exports.getInstance = (rid)->
    return util.singletons("gamefsm:#{rid}", ->create(rid))
