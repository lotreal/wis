'use strict';

angular.module('myNewProjectApp')
  .controller('MainCtrl', function ($scope, $http) {
    $scope.isSpecificPage = function() {
      return false;
    };

    $http.get('/api/awesomeThings').success(function(awesomeThings) {
      $scope.awesomeThings = awesomeThings;
    });
  });
