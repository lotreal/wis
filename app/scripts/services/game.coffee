'use strict'

angular.module('wis.game', ['wis.api'])

.factory("game", [
    "api", "$q"
    (api, $q) ->
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

                            _.map data.members, (p)->
                                Player.setFlag(p)

                            model.members = data.members

                            $scope.action = ->
                                game.handle('action')

                            $scope.speak = (evt)->
                                if evt.keyCode == 13
                                    if $scope.input
                                        socket.emit 'game:speak', $scope.input
                                        $scope.input = ''

                            state = data.state
                            @transition if state then state else 'ready'

                    ready:
                        _onEnter: ->
                            model.round = 0
                            @handle('usermod', Player.me())

                            $scope.getBoard = ->
                                num = model.members.length
                                api.printf(model.room.team, num) if num > 0

                            $('#wis-input').focus()
                            console.log 'enter waitroom'

                        load: (data)->
                            # TODO fix this
                            model.chats = [0..99]

                        action: (data)->
                            if Player.flag() == 'master'
                                socket.emit 'game:start', {}
                                console.log 'start game'
                            else
                                socket.emit 'game:ready', model.profile.uid

                        usermod: (data)->
                            return unless data
                            Player.setFlag(data)
                            console.log "#{data.uid} have been ready", data

                            find = Player.find(data)
                            flag = _.merge(find, data)

                            if Player.isMe(find)
                                label = '准备'
                                label = '取消准备' if find.flag == 'ready'
                                label = '开始' if find.flag == 'master'
                                model.actionLabel = label


                        getMaster: (master)->
                            console.log setMaster: master
                            @master.role = '' if @master
                            @master = master
                            master.role = 'master'
                            if master.uid == model.profile.uid
                                @transition 'master@waitroom'

                    play:
                        _onEnter: ->
                            $scope.vote = (idx)->
                                socket.emit 'game:vote', idx, (res)->
                                    $scope.subtitle = res

            )
            return game
        return fsm
])
