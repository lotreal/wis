'use strict'
app = angular.module('myNewProjectApp', [
    # Angular modules
    'ngRoute'
    'ngAnimate'

    # 3rd Party Modules
    'ui.bootstrap'
    'app.localization'
    'app.directives'
])

app.config ($routeProvider, $locationProvider) ->
    $routeProvider.when('/',
        redirectTo: '/signin'
        # templateUrl: 'partials/main'
        # controller: 'MainCtrl'
    ).when('/ui',
        templateUrl: 'partials/ui'
        controller: 'UiCtrl'
    ).when('/wis',
        templateUrl: 'partials/wis'
        controller: 'WisCtrl'
    ).when('/pm',
        templateUrl: 'partials/pm'
        controller: 'MainCtrl'
    ).when('/signin',
        templateUrl: 'partials/signin'
        controller: 'MainCtrl'
    ).otherwise redirectTo: '/'
    $locationProvider.html5Mode true
    return

app.factory 'socket', ($rootScope, $location) ->
    sio = io.connect()
    sio.socket.on('error', (reason)->
        console.log('Unable to connect Socket.IO: ' + reason)
        $location.path '/signin'
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

app.factory('Passport', [
    '$q', '$cookies', '$cookieStore', 'SDK'
    ($q, $cookies, $cookieStore, SDK)->
        token = 'user'
        signin = '/pages/signin'
        console.log $cookies
        exports =
            check: ->
                defered = $q.defer()
                if $cookies[token]?
                    defered.resolve()
                else
                    defered.reject(signin)
                defered.promise

            auth: (user, pass)->
                promise = SDK.api('passport/auth',  {login:user, pass:pass})
                promise.then(
                    (ok)->
                        console.log ok
                        $cookies[token] = ok.usercode
                )
                return promise

            getCurrentUser: ->
                $cookies[token]

            logout: ->
                $cookieStore.remove token

        return exports
])
