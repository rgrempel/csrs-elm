'use strict';

angular.module('csrsApp').controller('ProcessFormsDetailController', function ($scope, $stateParams, Contact) {
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

    $scope.doDelete = function () {
        Contact.delete({id: contact.id}, function () {
            // Change state ...
        });
    };

    $scope.createAnnual = function () {
        
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
