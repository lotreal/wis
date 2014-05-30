'use strict'

angular.module('wis.app', ['wis.connect', 'wis.game'])

.controller('WisCtrl', ($scope, $routeParams, connectService, game) ->
    rid = $routeParams.roomId
    game = game(rid, $scope)

    connectService.setup(game)
    return
)
