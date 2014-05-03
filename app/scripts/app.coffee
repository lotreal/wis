'use strict'
app = angular.module('WisApp', [
    # Angular modules
    'ngRoute'
    'ngCookies'
    'ngAnimate'

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
            redirectTo: '/signin'
        ).when('/ui',
            templateUrl: 'partials/ui'
            controller: 'MainCtrl'
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

app.run [
    '$rootScope', '$location', '$cookies'
    ($rootScope, $location, $cookies)->
        $location.path '/signin' unless $cookies['wis:uid']
]
