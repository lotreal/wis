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

                socket.on 'game:player:update', (data) ->
                    fsm.handle('load', data)

                socket.on 'game:chat', (data)->
                    fsm.handle('speak', data)

                socket.on 'game:start:count', (data) ->
                    $scope.subtitle = sprintf(data.message, data.count)

                socket.on 'game:deal', (game)->
                    $scope.board = game.word

                socket.on 'game:play:begin', (round)->
                    $scope.subtitle = sprintf('康熙字典（第 %d 版）', round)
                    $scope.list = []

                socket.on 'game:vote:begin', ->
                    $scope.subtitle = '请点选投票'

                socket.on 'game:vote:result', (vote)->
                    $scope.list = vote

                socket.on 'game:speak', (msg)->
                    console.log msg
                    $scope.list = msg

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
