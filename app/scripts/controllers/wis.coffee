'use strict'

app.controller 'WisCtrl', ['$scope', 'socket', ($scope, socket) ->
    title = (n)->
        a = ['一','二','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六','十七','十八','十九','廿','廿一','廿二','廿三','廿四']
        a[n-1]

    $scope.fmt = title
    $scope.subtitle = '现代汉语词典（第6版）'

    $scope.print = ->console.log 'print'

    socket.emit 'room:enter', {}, (profile)->
        console.log profile

    socket.on 'room:enter', (msg) ->
        console.log msg

    socket.on 'room:join', (data) ->
        console.log data
        $scope.players = data
        $scope.title = '神州' + title(data.length) + '杰'

    socket.on 'count', (data) ->
        $scope.subtitle = sprintf(data.message, data.count)

    socket.on 'start:game', (data)->
        $scope.subtitle = '现代汉语词典（第6版）'
        $scope.title = data

    $scope.startGame = ->
        console.log 'start'
        socket.emit 'start:game', {}
]
