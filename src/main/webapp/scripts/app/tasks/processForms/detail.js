'use strict';

angular.module('csrsApp').controller('ProcessFormsDetailController', function (
        $scope, $stateParams, Contact, Annual, _, $http, $window) {
        
    $scope.contact = {};

    $scope.load = function (id) {
        Contact.get({
            id: id,
            withAnnuals: true
        }, function(result) {
            $scope.contact = result;
            $('#saveContactModal').modal('hide');
        }, function(error) {
            
        });
    };

    $scope.load($stateParams.id);

    $scope.startEditing = function () {
        $('#saveContactModal').modal('show');
    };

    $scope.save = function () {
        Contact.update({}, $scope.contact, function () {
            $scope.load($scope.contact.id);
        }, function (error) {
            
        });
    };

    $scope.cancel = function () {
        $scope.load($stateParams.id);
    };

    $scope.checkDelete = function () {
        $('#deleteContactConfirmation').modal('show');
    };

    $scope.doDelete = function (id) {
        $window.alert("bob " + id);
//        Contact.delete({id: contact.id}, function () {
            // Change state ...
  //      });
    };

    $scope.deleteAnnual = function (annual) {
        Annual.delete({id: annual.id}, function () {
            _.pull($scope.contact.annuals, annual);
        }, function () {
            // Error
        })
    };

    $scope.createAnnual = function () {
        // Default to the current year, or the next year if there
        // is already an entry for the current year
        var thisYear = new Date().getFullYear();
        while (_.find($scope.contact.annuals, {year: thisYear})) {
            thisYear += 1;
        }

        var newAnnual = {
            year: thisYear,
            membership: 2, // default to regular member
            iter: false,
            rr: 0,
            contact: {
                id: $scope.contact.id
            }
        };

        Annual.save({}, newAnnual, function (value, headers) {
            $http.get(headers('location')).success(function (data) {
                $scope.contact.annuals.push(data);
            }).error(function () {
                // Shouldn't happen ...
            });
        }, function (httpResponse) {
            // error
        });
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('processFormsDetail', {
        parent: 'processForms',
        url: '/processForms/contact/:id',
        data: {
            roles: ['ROLE_ADMIN'],
            pageTitle: 'csrsApp.processForms.detail.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/tasks/processForms/detail.html',
                controller: 'ProcessFormsDetailController'
            }
        },
        resolve: {
            translatePartialLoader: ['$translate', '$translatePartialLoader', function ($translate, $translatePartialLoader) {
                $translatePartialLoader.addPart('processForms');
                $translatePartialLoader.addPart('contact');
                $translatePartialLoader.addPart('annual');
                $translatePartialLoader.addPart('global');
                return $translate.refresh();
            }]
        }
    });
});
