'use strict'

angular.module('wis.game', ['wis.api'])

.factory("game", [
    "api", "$q"
    (api, $q) ->
        timeoutHandler = {}
        setTimeoutIfNo = (fn, timeout, key)->
            clearTimeout(timeoutHandler[key])
            timeoutHandler[key] = setTimeout(fn, timeout)

        fsm = ($scope, socket) ->
            model = $scope.model

            class Player
                @get: (p)->
                    return new Player(p.uid)

                constructor: (@uid) ->

                @setFlag: (p)->
                    p.flag = ''
                    p.flag = 'ready' if p.isReady
                    p.flag = 'master' if p.isMaster
                    return p

                @find: (player)->
                    return _.find model.members, (p)->p.uid == player.uid

                @isMe: (player)->
                    return player.uid == model.profile.uid

                @me: ->
                    @find(model.profile)

                @flag: ->
                    @setFlag(@me()).flag

                @setBalloon: (uid, message)->
                    index = _.findIndex(model.members, uid:uid)
                    model.chats[index] = message
                    # trigger 'focus' let popover show
                    ballon = $('#balloon-'+index)
                    ballon.triggerHandler('focus')
                    hide = ->ballon.triggerHandler('blur')
                    setTimeoutIfNo(hide, 6000, "hide-ballon-#{uid}")

                @allReady: ->
                    _.every(model.members, (p)->p.isMaster || p.isReady)


            game = new machina.Fsm(
                initialState: 'uninitialized'
                namespace: 'wis'

                sync: (rid)->
                    console.log 'sync game data'
                    api.getRoom(rid).then(
                        _.bind(
                            (data)->
                                @handle('initialized', data)
                                @handle('load', data)
                            @
                        )
                        (err)->
                    )

                states:
                    uninitialized:
                        initialized: (data)->
                            console.log load: data
                            model.room = data.room
                            model.profile = data.profile

                            # TODO fix this
                            model.chats = [0..99]

                            $scope.action = ->
                                game.handle('action')

                            $scope.speak = (evt)->
                                if evt.keyCode == 13
                                    if $scope.input
                                        socket.emit 'game:speak', $scope.input
                                        console.log 'input - ', $scope.input
                                        $scope.input = ''

                            $scope.print = ->console.log 'print'

                            state = data.state
                            @transition if state then state else 'ready'

                    ready:
                        _onEnter: ->
                            model.round = 0

                            $scope.getBoard = ->
                                num = model.members.length
                                api.teamname(model.room.team, num) if num > 0

                            $scope.isVisible = (key)->
                                return key == 'ready'

                            $scope.actionAvailable = ->
                                return true if Player.flag() != 'master'
                                return Player.allReady()

                            $('#wis-input').focus()
                            console.log 'enter waitroom'

                        load: (data)->
                            _.map data.members, (p)->
                                Player.setFlag(p)
                            model.members = data.members
                            @handle('usermod', Player.me())

                        action: (data)->
                            if Player.flag() == 'master'
                                console.log Player.allReady()
                                # socket.emit 'wis:start', {}
                                console.log 'start game'
                                @transition('play')
                            else
                                socket.emit 'wis:ready', model.profile.uid
                                console.log 'ready'

                        usermod: (data)->
                            return unless data
                            Player.setFlag(data)
                            console.log "usermod #{data.uid}", data

                            find = Player.find(data)
                            flag = _.merge(find, data)

                            if Player.isMe(find)
                                label = '准备'
                                label = '取消准备' if find.flag == 'ready'
                                label = '开始' if find.flag == 'master'
                                model.actionLabel = label

                        speak: (chat)->
                            console.log "chat - #{chat.uid}: #{chat.message}"
                            Player.setBalloon(chat.uid, chat.message)

                    play:
                        _onEnter: ->
                            $scope.isVisible = (key)->
                                return key == 'play'

                            $scope.vote = (idx)->
                                socket.emit 'game:vote', idx, (res)->
                                    $scope.subtitle = res

            )
            return game
        return fsm
])
