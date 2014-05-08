'use strict'

angular.module('wis.game', ['wis.api'])

.factory("game", [
    "api", "$q"
    (api, $q) ->
        fsm = ($scope, socket) ->
            model = $scope.model

            ImMaster = ->
                master = _.find model.members, (p)->
                    p.flag == 'master' && p.uid == model.profile.uid
                return _.isObject(master) && master.uid == model.profile.uid

            bootstrap = (game)->
                return

            game = new machina.Fsm(
                initialState: 'uninitialized'
                namespace: 'wis'

                sync: (rid)->
                    console.log 'sync game data'
                    api.getRoom(rid).then _.bind(@load, @)

                load: (data)->
                    console.log load: data
                    model.room = data.room
                    model.profile = data.profile
                    model.members = data.members

                    # TODO fix this
                    model.chats = [0..99]

                    $scope.start = ->
                        game.handle('action')

                    $scope.startGame = ->
                        console.log 'start'
                        socket.emit 'game:start', {}

                    $scope.vote = (idx)->
                        socket.emit 'game:vote', idx, (res)->
                            $scope.subtitle = res

                    $scope.keyPress = (evt)->
                        if evt.keyCode == 13
                            if $scope.input
                                socket.emit 'game:speak', $scope.input
                                $scope.input = ''

                    $scope.print = ->console.log 'print'

                    $scope.debug = ->
                        console.log 'debug'
                        api.testll()
                        socket.emit 'game:debug', {}

                    @transition if model.state then model.state else 'waitroom'

                states:
                    uninitialized:
                        initialized: (data)->
                            initialized: (data)->


                    waitroom:
                        _onEnter: ->
                            @round = 0
                            $('#wis-input').focus()
                            $scope.getBoard = ->
                                num = model.members.length
                                api.printf(model.room.team, num) if num > 0

                            model.waitRoomAction = if ImMaster() then '开始' else '准备'
                            @handle 'getReady'

                            console.log 'enter waitroom'

                        async: (data)->

                        action: (data)->
                            unless ImMaster()
                                socket.emit 'game:ready', model.profile.uid
                            else
                                console.log 'start game'

                        getReady: (data)->
                            console.log 'getReady'
                            return unless data
                            find = _.find model.members, (p)->p.uid == data.uid
                            find.ready = data.ready
                            if find.uid == model.profile.uid
                                model.waitRoomAction = if find.ready then '取消准备' else '准备'


                        getMaster: (master)->
                            console.log setMaster: master
                            @master.role = '' if @master
                            @master = master
                            master.role = 'master'
                            if master.uid == model.profile.uid
                                @transition 'master@waitroom'

                    'master@waitroom':
                        _onEnter: ->
                            model.waitRoomAction = '开始'
            )
            return game
        return fsm
])
