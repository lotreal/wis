'use strict'

angular.module('wis.player', [])

.factory("playerService", ->
    class Player
        @init: (myuid, members)->
            Player.myuid = myuid
            Player.members = members

        @setFlag: (p)->
            p.flag = ''
            p.flag = 'ready' if p.isReady
            p.flag = 'master' if p.isMaster
            return p

        @find: (player)->
            return _.find Player.members, (p)->p.uid == player.uid

        @isMe: (player)->
            return player.uid == Player.myuid

        @me: ->
            @find(uid:Player.myuid)

        @flag: ->
            @setFlag(@me()).flag

        @setBalloon: (model, uid, message)->
            return unless message
            index = _.findIndex(Player.members, uid:uid)
            model.chats[index] = message
            # trigger 'focus' let popover show
            ballon = $('#balloon-'+index)
            ballon.triggerHandler('focus')
            hide = ->ballon.triggerHandler('blur')
            setTimeoutIfNo(hide, 7000, "hide-ballon-#{uid}")

        @allReady: ->
            _.every(Player.members, (p)->p.isMaster || p.isReady)
)
