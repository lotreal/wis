'use strict'
angular.module('myNewProjectApp').controller 'WisCtrl', [
    '$scope', 'socket', '$routeParams'
    ($scope, socket, $routeParams) ->
        # console.log $routeParams.roomId
        fmt = (n)->
            a = ['一','二','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六','十七','十八','十九','廿','廿一','廿二','廿三','廿四']
            a[n-1]

        $scope.fmt = fmt
        $scope.subtitle = '现代汉语词典（第6版）'

        $scope.print = ->console.log 'print'

        $scope.startGame = ->
            console.log 'start'
            socket.emit 'game:start', {}

        $scope.vote = (idx)->
            console.log 'vote'+idx
            socket.emit 'game:vote', idx

        $scope.keyPress = (evt)->
            if evt.keyCode == 13
                socket.emit 'game:speak', $scope.input
                $scope.input = ''

        socket.on 'game:player:update', (data) ->
            console.log data
            $scope.players = data.players
            $scope.subtitle = sprintf(data.teamname, fmt(data.players.length))

        socket.on 'game:start:count', (data) ->
            $scope.subtitle = sprintf(data.message, data.count)

        socket.on 'game:deal', (game)->
            $scope.subtitle = sprintf('现代汉语词典（第 %d 版）', game.round)
            $scope.title = game.word
            $scope.players = []

        socket.on 'game:speak', (msg)->
            console.log msg
            $scope.players = msg

        return
]
