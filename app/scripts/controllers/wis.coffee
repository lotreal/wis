'use strict'
angular.module('WisApp').controller 'WisCtrl', [
    '$scope', 'socketFactory', '$routeParams'
    ($scope, socketFactory, $routeParams) ->
        socket = socketFactory({
            ioSocket: io.connect('', query: "rid=1ntlvb7r&token=t")
        })

        # console.log $routeParams.roomId

        fmt = (n)->
            a = ['一','双','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六','十七','十八','十九','廿','廿一','廿二','廿三','廿四']
            a[n-1]

        $scope.fmt = fmt
        $scope.subtitle = '现代汉语词典（第6版）'
        $scope.title = "<-点击开始"
        $scope.print = ->console.log 'print'

        $scope.debug = ->
            console.log 'debug'
            socket.emit 'game:debug', {}

        $scope.startGame = ->
            console.log 'start'
            socket.emit 'game:start', {}

        $scope.vote = (idx)->
            $scope.subtitle = '您已投票给 ' + (idx+1) + ' 号，等其他人投票后显示投票结果。'
            socket.emit 'game:vote', idx

        $scope.keyPress = (evt)->
            if evt.keyCode == 13
                socket.emit 'game:speak', $scope.input
                $scope.input = ''

        socket.emit 'game:create', {}, (room)->
            $scope.room = room

        socket.on 'game:player:update', (list) ->
            $scope.list = list
            $scope.subtitle = sprintf($scope.room.team, fmt($scope.list.length))

        socket.on 'game:start:count', (data) ->
            $scope.subtitle = sprintf(data.message, data.count)

        socket.on 'game:deal', (game)->
            $scope.title = game.word

        socket.on 'game:play:begin', (round)->
            $scope.subtitle = sprintf('现代汉语词典（第 %d 版）', round)
            $scope.list = []

        socket.on 'game:vote:begin', ->
            $scope.subtitle = '请点选投票'

        socket.on 'game:vote:result', (vote)->
            $scope.subtitle = '投票结果'
            $scope.list = vote

        socket.on 'game:speak', (msg)->
            console.log msg
            $scope.list = msg

        return
]
