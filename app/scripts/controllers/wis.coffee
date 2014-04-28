'use strict'

app.controller 'WisCtrl', ['$scope', 'socket', ($scope, socket) ->
    $scope.title = 'Room'

    socket.emit 'room:enter', {}, (profile)->
        console.log profile

    socket.on 'room:enter', (msg) ->
        console.log msg

    socket.on 'room:join', (data) ->
        console.log data
        $scope.players = data
        $scope.player_num = data.length

]
