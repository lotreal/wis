'use strict'
angular.module('myNewProjectApp').controller 'MainCtrl', ($scope, $http, $location) ->
    $scope.username = '罗涛'
    $scope.login = ->
        $http.post('/login', {name: $scope.username})
        .success((res)->
            [err, token] = res
            return console.log err if err
            console.log token
            $location.path '/wis'
        )
        .error((err)->
            console.log err
        )

    $scope.isSpecificPage = ->
        false

    # $http.get('/api/awesomeThings').success (awesomeThings) ->
    #     $scope.awesomeThings = awesomeThings
    #     return

    return
