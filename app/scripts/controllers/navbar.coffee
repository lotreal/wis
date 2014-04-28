"use strict"
angular.module("myNewProjectApp").controller "NavbarCtrl", ($scope, $location) ->
    $scope.menu = [
        {
            title: "Home"
            link: "/"
        }
        {
            title: "UI"
            link: "/ui"
        }
        {
            title: "SignIn"
            link: "/signin"
        }
        {
            title: "wis"
            link: "/wis"
        }
    ]
    $scope.isActive = (route) ->
        route is $location.path()

    return

