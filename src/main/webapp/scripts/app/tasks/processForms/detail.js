'use strict';

angular.module('csrsApp').controller('ProcessFormsDetailController', function ($scope, $stateParams, Contact) {
    $scope.contact = {};
    $scope.load = function (id) {
        Contact.get({id: id}, function(result) {
            $scope.contact = result;
        });
    };
    $scope.load($stateParams.id);
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
                return $translate.refresh();
            }]
        }
    });
});
