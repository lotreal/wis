'use strict';

angular.module('myNewProjectApp')
  .controller('NavbarCtrl', function ($scope, $location) {
    $scope.menu = [{
      'title': 'Home',
      'link': '/'
    },{
      'title': 'UI',
      'link': '/ui'
    }];

    $scope.isActive = function(route) {
      return route === $location.path();
    };
  });
