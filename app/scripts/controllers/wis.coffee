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
            waitRoomAction: '准备'

        bootstrap = (ui, socket)->
            # ui.chats = []
            # TODO fix this
            ui.chats = [0..99]
            ui.print = ->console.log 'print'

            ui.debug = ->
                console.log 'debug'
                api.testll()
                socket.emit 'game:debug', {}

            ui.start = ->
                socket.emit 'game:ready', model.profile.uid

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
                    initialized: ->
                        @socket = connect.room($scope, @, '')
                        bootstrap($scope, @socket)
                        $('#wis-input').focus()
                        @transition 'waitroom'

                waitroom:
                    _onEnter: ->
                        @round = 0
                        $scope.getBoard = ->
                            num = model.members.length
                            api.printf(model.room.team, num) if num > 0
                        console.log 'enter waitroom'

                    setMaster: (player)->
                        @master.role = '' if @master
                        @master = player
                        player.role = 'master'
                        if player.uid == model.profile.uid
                            @transition 'master@waitroom'

                'master@waitroom':
                    _onEnter: ->
                        model.waitRoomAction = '开始'
        )


        api.getRoom($routeParams.roomId).then(
            (data)->
                console.log data
                model.room = data.room
                model.profile = data.profile
                model.members = data.members
                game.handle('initialized')

            (err)->
                console.log err
        )

        return
])
