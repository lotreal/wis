'use strict'
angular.module('WisApp').controller 'MainCtrl', [
    '$scope', '$http', '$location'
    ($scope, $http, $location) ->
        $scope.username = '罗涛'

        $scope.login = ->
            $http.post('/login', {name: $scope.username})
            .success((res)->
                [err, token] = res

                if err
                    console.log err
                    alert(err)
                    return

                $location.path '/wis'
            )
            .error((err)->
                console.log err
            )

        $scope.isSpecificPage = ->
            true
        return
    ]
