'use strict'
sn = require('./sn')

class MessageStore
    constructor: (@team) ->
        @logs = {}
        @full = {}

    log: (page, from, message)->
        page = "page-#{page}"
        unless @logs[page]
            @logs[page] = {}
        @logs[page][from.id] = message
        return

    vote: (round, from, target)->

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
            "#{sn.cnNum(i+1)}、#{result}"
        messages = (d(player, i) for player, i in @team.members())
        @full["page-#{page}"] = myturn
        return messages

    fullpage: (page)->
        @full["page-#{page}"]

exports.MessageStore = MessageStore
