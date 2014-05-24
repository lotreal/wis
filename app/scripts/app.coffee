'use strict'
app = angular.module('WisApp', [
    # Angular modules
    'ngRoute'
    'ngCookies'
    'ngAnimate'

    'wis.app'

    # 3rd Party Modules
    'btford.socket-io'
    'ui.bootstrap'
    'app.localization'
    'app.directives'
])

app.config [
    '$routeProvider'
    '$locationProvider'
    ($routeProvider, $locationProvider) ->
        $routeProvider.when('/',
            redirectTo: '/1ntlvb7r'
        ).when('/ui',
            templateUrl: 'partials/game'
            controller: 'MainCtrl'
        ).when('/signin',
            templateUrl: 'partials/signin'
            controller: 'MainCtrl'
        ).when('/:roomId',
            templateUrl: 'partials/game'
            controller: 'WisCtrl'
        ).otherwise redirectTo: '/'
        $locationProvider.html5Mode true
        return
    ]

app.run [
    '$rootScope', '$location', '$cookies'
    ($rootScope, $location, $cookies)->
        # $location.path '/signin' unless $cookies['wis:uid']
]
