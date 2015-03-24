'use strict';

angular.module('csrsApp').controller('ProcessFormsController', function ($scope, $state, $stateParams, Contact, $http, $location) {
    this.search = $stateParams.search;
    this.contact = {};

    this.errorMessage = '';
    this.searchStatus = '';

    this.performSearch = function () {
        var self = this;

        if ($location.search('search') !== this.search) {
            $location.search('search', this.search);
            $location.replace();
        }

        if (this.search) {
            this.searchStatus = 'csrsApp.processForms.searchStatus.searching';
            Contact.query({
                fullNameSearch: self.search
            }, function (result) {
                if (result.length === 0) {
                    self.searchStatus = 'csrsApp.processForms.searchStatus.notFound';
                } else {
                    self.searchStatus = '';
                }
                self.errorMessage = '';
                self.results = result;
            }, function (error) {
                self.searchStatus = '';
                self.results = [];
                self.errorMessage = error.statusText;
            });
        } else {
            self.searchStatus = '';
            self.results = [];
        }
    };

    this.startEditing = function () {
        $state.go('createContact');
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
