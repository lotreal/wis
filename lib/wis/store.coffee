'use strict'

Fmt = require('./sn')
Vote = require('./vote')

module.exports = (->
    class MessageStore
        constructor: (@team) ->
            @logs = {}
            @votes = []
            @full = {}

        log: (page, from, message)->
            page = "page-#{page}"
            unless @logs[page]
                @logs[page] = {}
            @logs[page][from.id] = message
            return

        prepareVote: ->
            @currentVote = new Vote(@team.length())
            return

        vote: (round, from, target)->
            @currentVote.vote(@team.index(socketID: from.id), target)

        completeVote: ->
            return @currentVote.end().end

        getVoteResult: (team, round)->
            players = team.player()
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

            messages = (d(player, i) for player, i in @team.member())
            @full["page-#{page}"] = myturn
            return messages

        fullpage: (page)->
            @full["page-#{page}"]

    return MessageStore
)()
