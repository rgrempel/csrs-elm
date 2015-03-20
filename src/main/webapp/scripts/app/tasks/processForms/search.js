'use strict';

angular.module('csrsApp').controller('ProcessFormsController', function ($stateParams, Contact, $location) {
    this.search = $stateParams.search;

    this.performSearch = function () {
        var self = this;

        if ($location.search('search') != this.search) {
            $location.search('search', this.search);
            $location.replace();
        }

        if (this.search) {
            Contact.query({
                fullNameSearch: self.search
            }, function (result, headers) {
                self.results = result;
            }, function (error) {

            });
        } else {
            self.results = [];
        }
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
