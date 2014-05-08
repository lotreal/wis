'use strict'

angular.module('wis.connect', [])

.factory('connect', [
    'socketFactory'
    (socketFactory) ->
        return {
            room: ($scope, game, rid)->
                model = $scope.model

                socket = socketFactory({
                    ioSocket: io.connect('', query: 'rid=1ntlvb7r&token=t')
                })

                # socket.on 'connect', ->

                socket.on 'game:player:update', (data) ->
                    console.log 'game:player:update': data
                    $scope.model.members = data.members

                socket.on 'game:chat', (chat)->
                    index = chat.index
                    $scope.chats[index] = chat.message
                    console.log "#{index}: #{chat.message}"
                    el = $('#balloon-'+index)
                    el.triggerHandler('focus')



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

                socket.on 'game:ready', (data)->
                    game.handle('getReady', data)

                return socket
        }
])
