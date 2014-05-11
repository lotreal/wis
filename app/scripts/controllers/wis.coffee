'use strict'

angular.module('wis.app', ['wis.game', 'wis.connect', 'wis.api'])

.controller('WisCtrl', [
    '$scope', 'game', 'api', 'connect', '$routeParams', 'localize', '$cookies'
    ($scope, game, api, connect, $routeParams, localize, $cookies) ->
        model = $scope.model =
            board: undefined
            room: undefined
            profile: undefined
            members: []

        socket = connect.create($routeParams.roomId)
        socket.on 'connect', ->
            console.log 'wis connected.'
            game = game($scope)
            game.sync($routeParams.roomId, socket)
            connect.setup(socket, game)

        return
])
