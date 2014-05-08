'use strict'

angular.module('wis.app', ['wis.connect', 'wis.api'])

.controller('WisCtrl', [
    '$scope', 'api', 'connect', '$routeParams', 'localize', '$cookies'
    ($scope, api, connect, $routeParams, localize, $cookies) ->
        model = $scope.model =
            board: undefined
            room: undefined
            profile: undefined
            members: []

        ImMaster = ->
            master = _.find model.members, (p)->
                p.flag == 'master' && p.uid == model.profile.uid
            return _.isObject(master) && master.uid == model.profile.uid

        bootstrap = (ui, game, socket)->
            # ui.chats = []
            # TODO fix this
            ui.chats = [0..99]
            ui.print = ->console.log 'print'

            ui.debug = ->
                console.log 'debug'
                api.testll()
                socket.emit 'game:debug', {}

            ui.start = ->
                game.handle('action')

            ui.startGame = ->
                console.log 'start'
                socket.emit 'game:start', {}

            ui.vote = (idx)->
                socket.emit 'game:vote', idx, (res)->
                    ui.subtitle = res

            ui.keyPress = (evt)->
                if evt.keyCode == 13
                    if ui.input
                        socket.emit 'game:speak', ui.input
                        ui.input = ''

            return

        # ($scope, connect)
        game = new machina.Fsm(
            initialState: 'uninitialized'
            states:
                uninitialized:
                    initialized: (data)->
                        model.room = data.room
                        model.profile = data.profile
                        model.members = data.members

                        @socket = connect.room($scope, @, '')
                        bootstrap($scope, @, @socket)

                        @transition if model.state then model.state else 'waitroom'

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
                            @socket.emit 'game:ready', model.profile.uid
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


        api.getRoom($routeParams.roomId).then(
            (data)->
                console.log data
                game.handle('initialized', data)

            (err)->
                console.log err
        )

        return
])
