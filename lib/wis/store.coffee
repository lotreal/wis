'use strict'

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
