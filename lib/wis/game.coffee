'use strict'
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
            team.broadcast evt, {count: count--, message: message}

            if (count > 0)
                setTimeout(fn, 1000)
            else
                setTimeout(done, 1000)
        return fn()

    updatePlayer = (team)->
        list = (p.profile.slogan for p in team.member())
        team.broadcast 'game:player:update', Fmt.list(list)

    # TODO move to utils
    sliceRnd = (collection, n)->
        head = _.sample(collection, n)
        tail = _.filter(collection, (i)->!_.contains(head, i))
        return [head, tail]

    startGame = (team, game)->
        done = ->
            team.beforePlay()

            words = word()

            team.send 'civil', 'game:deal', word: words[0]
            team.send 'spy', 'game:deal', word: words[1]

            game.setMachineState(game.PLAY)

        countdown(team, 'game:start:count', 2, '服务器正在出题(%d)', done)


    game = Stately.machine({
        READY:
            init: ->
                @team = context.one('team:'+rid, ()->new Team(rid, io))
                postal.subscribe(
                    channel  : 'game'
                    topic    : "member.change"
                    callback : (team, envelope)->
                        updatePlayer(team)
                )
                @logger = new Logger(@team)

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
                @team.broadcast 'game:speak', Fmt.list(@logger.show(@round))

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
                    players = @team.member()
                    messages = @logger.show(@round)
                    result = @logger.currentVote.result()

                    icon = '<span class="glyphicon glyphicon-hand-left"></span>'
                    icon = ''
                    list = []
                    for m, i in messages
                        V = result[i]
                        # voteme = (icon+Fmt.N(v) for v in V.voted).join(' ')
                        voteme = ''
                        line = "#{m} <- 共 #{V.getted} 票: (#{voteme}) "
                        if V.hit
                            line = line + '【最高票】'
                            players[i].state = 'OUT'
                            @team.remove(players[i])
                        list.push(line)
                    #console.log players
                    @team.broadcast 'game:vote:result', Fmt.list(list)

                    win = (team)->
                        leftSpy = (_.filter team.member(), (p)->p.role=='SPY')
                        return 'CIVIL' if leftSpy == 0
                        return 'SPY' if team.length() <=3
                        return false

                    gameover = (team, win)->
                        print = (p)->
                            line = p.profile.slogan
                            line += p.role
                            line += (if p.role == win then '【赢】' else '【输】')
                            return line
                        list = (print(p) for p in team.member())
                        team.broadcast 'game:over', Fmt.list(list)

                    whowin = win(@team)
                    if whowin
                        gameover(@team, whowin)
                        return @OVER

                    self = @
                    done = ->
                        self.setMachineState(self.PLAY)

                    countdown(@team, 'game:start:count', 9, '投票结果(%d)', done)

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
