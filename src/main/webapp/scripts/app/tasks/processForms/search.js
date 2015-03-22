'use strict';

angular.module('csrsApp').controller('ProcessFormsController', function ($scope, $state, $stateParams, Contact, $http, $location) {
    this.search = $stateParams.search;
    this.contact = {};

    this.performSearch = function () {
        var self = this;

        if ($location.search('search') !== this.search) {
            $location.search('search', this.search);
            $location.replace();
        }

        if (this.search) {
            Contact.query({
                fullNameSearch: self.search
            }, function (result) {
                self.results = result;
            }, function () {

            });
        } else {
            self.results = [];
        }
    };

    this.startEditing = function () {
        $scope.$broadcast('startEditing');
    };
    
    this.save = function () {
        Contact.save({}, this.contact, function (value, headers) {
            $http.get(headers('location')).success(function (data) {
                $state.go('processFormsDetail', {
                    id: data.id
                });
            });
        }, function () {
            
        });
    };

    this.cancel = function () {
        this.contact = {};
    };

    // Initial search if we had params
    this.performSearch();
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
                controller: 'ProcessFormsController',
                controllerAs: 'search'
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
