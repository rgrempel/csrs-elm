'use strict';

angular.module('csrsApp')
    .controller('AnnualDetailController', function ($scope, $stateParams, Annual, Contact) {
        $scope.annual = {};
        $scope.load = function (id) {
            Annual.get({id: id}, function(result) {
              $scope.annual = result;
            });
        };
        $scope.load($stateParams.id);
    });
