'use strict'

app.controller 'WisCtrl', ['$scope', 'socket', ($scope, socket) ->
  $scope.title = 'Room'

  context =
    user:
      id: 1
      name: 'lot'

    room:
      id: 'tuhao'
      name: '我的土豪朋友们'

  socket.emit 'room:enter', context, (msg) ->
    $scope.title = msg

  socket.on 'room:join', (data) ->
    console.log data
]
