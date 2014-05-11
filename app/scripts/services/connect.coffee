'use strict'

angular.module('wis.connect', [])

.factory('connect', [
    'socketFactory'
    (socketFactory) ->
        return {
            create: (rid)->
                return socketFactory({
                    ioSocket: io.connect('', query: "rid=#{rid}")
                })

            room: (socket, fsm, model, $scope)->
                model = $scope.model

                socket.on 'wis:reflash', (data) ->
                    fsm.handle('load', data)

                socket.on 'wis:speak', (data)->
                    fsm.handle('speak', data)

                socket.on 'wis:start:forecast', (data)->
                    fsm.handle('start.forecast', data)

                socket.on 'wis:start:countdown', (data) ->
                    fsm.handle('start.countdown', data)

                socket.on 'wis:start', (game) ->
                    console.log game:game
                    $scope.board = game.word
                    fsm.handle('start', game)

                socket.on 'wis:start:round', (round)->
                    fsm.handle('start.round', round)

                socket.on 'game:vote:begin', ->
                    $scope.subtitle = '请点选投票'

                socket.on 'game:vote:result', (vote)->
                    $scope.list = vote

                socket.on 'game:over', (data)->
                    $scope.list = data
                    $scope.subtitle = '考试结果'

                socket.on 'game:set:master', (res)->
                    find = _.find model.members, (p)->p.uid == res.uid
                    find.flag = 'master'

                socket.on 'wis:usermod', (data)->
                    fsm.handle('usermod', data)

                return socket
        }
])
