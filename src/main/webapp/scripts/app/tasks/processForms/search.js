'use strict';

angular.module('csrsApp').controller('ProcessFormsController', function ($scope, $stateParams, Contact, $location) {
    $scope.search = $stateParams.search;

    $scope.performSearch = function () {
        if ($location.search('search') != $scope.search) {
            $location.search('search', $scope.search);
            $location.replace();
        }

        if ($scope.search) {
            Contact.query({
                fullNameSearch: $scope.search
            }, function (result, headers) {
                $scope.results = result;
            });
        } else {
            $scope.results = [];
        }
    };

    // Initial search if we had params
    $scope.performSearch();
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('processForms', {
        parent: 'tasks',
        url: '/process-forms?search',
        reloadOnSearch: false,
        data: {
            roles: ['ROLE_ADMIN'],
            pageTitle: 'csrsApp.processForms.home.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/tasks/processForms/search.html',
                controller: 'ProcessFormsController'
            }
        },
        resolve: {
            translatePartialLoader: ['$translate', '$translatePartialLoader', function ($translate, $translatePartialLoader) {
                $translatePartialLoader.addPart('processForms');
                return $translate.refresh();
            }]
        }
    });
});
