'use strict';

var app = angular.module('myNewProjectApp', [
  // Angular modules
  'ngRoute',
  'ngAnimate',

  // 3rd Party Modules
  'ui.bootstrap',
  // 'easypiechart',
  // 'mgo-angular-wizard',
  // 'textAngular',

  // Custom modules
  // 'app.ui.ctrls',
  // 'app.ui.directives',
  // 'app.ui.services',
  // 'app.controllers',
  // 'app.directives',
  // 'app.form.validation',
  // 'app.ui.form.ctrls',
  // 'app.ui.form.directives',
  // 'app.tables',
  // 'app.task',
  // 'app.localization',
  // 'app.chart.ctrls',
  // 'app.chart.directives'
  'app.directives'
]);

app.config(function ($routeProvider, $locationProvider) {
  $routeProvider
    .when('/', {
      templateUrl: 'partials/main',
      controller: 'MainCtrl'
    })
    .when('/ui', {
      templateUrl: 'partials/ui',
      controller: 'UiCtrl'
    })
    .when('/wis', {
      templateUrl: 'partials/wis',
      controller: 'WisCtrl'
    })
    .when('/signin', {
      templateUrl: 'partials/signin',
      controller: 'MainCtrl'
    })
    .otherwise({
      redirectTo: '/'
    });

  $locationProvider.html5Mode(true);
});

app.factory('socket', function ($rootScope) {
  var socket = io.connect();
  return {
    on: function (eventName, callback) {
      socket.on(eventName, function () {
        var args = arguments;
        $rootScope.$apply(function () {
          callback.apply(socket, args);
        });
      });
    },
    emit: function (eventName, data, callback) {
      socket.emit(eventName, data, function () {
        var args = arguments;
        $rootScope.$apply(function () {
          if (callback) {
            callback.apply(socket, args);
          }
        });
      })
    }
  };
});
