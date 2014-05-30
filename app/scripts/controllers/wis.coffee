'use strict'

angular.module('wis.app', ['wis.connect', 'wis.game'])

.controller('WisCtrl', ($scope, $routeParams, connectService, game)->
    rid = $routeParams.roomId
    connectService.handle(game(rid, $scope))
)
