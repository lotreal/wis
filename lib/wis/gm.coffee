'use strict'

_ = require('lodash')
Fmt = require('./sn')
Vote = require('./vote')
config = require('../config/config')
word = require('./word')

class Store
    constructor: (@fsm) ->
        @team = fsm.team

        @speaks = []

        @logs = {}
        @votes = []
        @full = {}

    generateWisWord: ->
        words = if config.env == 'development' then ['CIVIL','SPY'] else word()
        @wisWord = civil:words[0], spy:words[1]
        return

    getWisWord: (role)->
        return @wisWord[role]

    'play.speak': (data)->
        round = @fsm.round
        find = _.find @speaks, {round:round}
        @speaks.push(
            round: round
            player: data.player
            message: data.message
        )
        role = @team.getRole(data.player)
        return @getScene(role, round)

    start: ->
        @team.initGroup()
        @generateWisWord()

    getScene: (role, round)->
        next = false
        list = []
        for player, i in @team.getLeft()
            find = _.find @speaks, {round:round, player:player}
            if find
                if next
                    player.message = '*'
                else
                    player.message = find.message
            else
                next = player.uid
                player.message = ''
            list.push(player)

        scene = speaks:list, next:next

        data =
            game:
                word: @getWisWord(role)
                round: round
            scene: scene
        return data

    log: (page, from, message)->
        page = "page-#{page}"
        unless @logs[page]
            @logs[page] = {}
        @logs[page][from.id] = message
        return

    loadWaitroom: ->
        players = _.map @team.getMember(), (p, i)->
            return {
                uid: p.getId()
                name: p.profile.name
                slogan: p.profile.slogan
                message: p.message

                isMaster: i == 0
                isReady: p.ready
            }
        return members: players

    prepareVote: ->
        @currentVote = new Vote(@team.getPlayer().length)
        return

    isVoted: (from)->
        @currentVote.isVoted(@team.index(socketID: from.id))

    vote: (round, from, target)->
        @currentVote.vote(@team.index(socketID: from.id), target)

    completeVote: ->
        return @currentVote.end().end

    getVoteResult: (team, round)->
        players = team.getPlayer()
        messages = @show(round)
        result = @currentVote.result()


        list = []
        voteme = (V)->
            icon = '<span class="glyphicon glyphicon-hand-left"></span>'
            icon = ''
            ("【#{Fmt.N(v)}】" for v in V.voted).join('')

        hit = -1
        for m, i in messages
            line = ''
            V = result[i]

            line = line + "#{m}   ————得 #{V.getted} 票 #{voteme(V)} "

            if V.hit
                hit = i
                line = line + '！'
                console.log nowhit: players[i]
                team.hit(players[i])


            list.push(line)

        conclusion = if hit == -1 then '无人离场' else "#{Fmt.N(hit)}号高票离场"
        return {
            title: "第#{Fmt.N(round-1)}场考试结果：#{conclusion} ... [%d]"
            list: list
        }

    getGameResult: (team, game)->
        spy = _.clone team.getSpy()
        hit = team.getHit()
        _.pull(spy, h) for h in hit

        winner = ''
        if spy.length == 0
            winner = 'civil'
        else
            if (team.getPlayer().length - hit.length <=3 )
                winner = 'spy'

        gameover = winner != ''
        list = []
        if gameover
            self = team
            console.log word:game.word
            print = (p)->
                role = self.getRole(p)
                line = p.profile.slogan
                line += '【考题】' + game.word[role]
                line += (if role == winner then '【高中】' else '')
                return line
            list = (print(p) for p in self.getPlayer())

        return {
            winner: winner
            gameover: winner != ''
            list: list
        }

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
            return result

        messages = (d(player, i) for player, i in @team.getMember())
        @full["page-#{page}"] = myturn
        return messages

    fullpage: (page)->
        @full["page-#{page}"]

module.exports = Store
