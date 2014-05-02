'use strict'
app = angular.module('myNewProjectApp', [
    # Angular modules
    'ngRoute'
    'ngCookies'
    'ngAnimate'

    # 3rd Party Modules
    'ui.bootstrap'
    'app.localization'
    'app.directives'
])

app.config [
    '$routeProvider'
    '$locationProvider'
    ($routeProvider, $locationProvider) ->
        $routeProvider.when('/',
            redirectTo: '/signin'
            # templateUrl: 'partials/main'
            # controller: 'MainCtrl'
        ).when('/signin',
            templateUrl: 'partials/signin'
            controller: 'MainCtrl'
        ).when('/:roomId',
            templateUrl: 'partials/wis'
            controller: 'WisCtrl'
        ).otherwise redirectTo: '/'
        $locationProvider.html5Mode true
        return
    ]

app.factory 'socket', [
    '$rootScope', '$location', '$cookies'
    ($rootScope, $location, $cookies) ->
        sio = io.connect()

        sio.socket.on('error', (reason)->
            console.log('Unable to connect Socket.IO: ' + reason)
        )

        sio.on('connect', ()->
            console.info('successfully established a working connection \o/')
        )

        on: (eventName, callback) ->
            sio.on eventName, ->
                args = arguments
                $rootScope.$apply ->
                    callback.apply sio, args
                    return

                return

            return

        emit: (eventName, data, callback) ->
            sio.emit eventName, data, ->
                args = arguments
                $rootScope.$apply ->
                    callback.apply sio, args if callback
                    return

                return

            return
]
app.run [
    '$rootScope', '$location', '$cookies'
    ($rootScope, $location, $cookies)->
        $location.path '/signin' unless $cookies['wis:uid']
]
