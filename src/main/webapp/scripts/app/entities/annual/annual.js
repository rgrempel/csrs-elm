'use strict';

angular.module('csrsApp')
    .config(function ($stateProvider) {
        $stateProvider
            .state('annual', {
                parent: 'entity',
                url: '/annual',
                data: {
                    roles: ['ROLE_USER'],
                    pageTitle: 'csrsApp.annual.home.title'
                },
                views: {
                    'content@': {
                        templateUrl: 'scripts/app/entities/annual/annuals.html',
                        controller: 'AnnualController'
                    }
                }
            })
            .state('annualDetail', {
                parent: 'entity',
                url: '/annual/:id',
                data: {
                    roles: ['ROLE_USER'],
                    pageTitle: 'csrsApp.annual.detail.title'
                },
                views: {
                    'content@': {
                        templateUrl: 'scripts/app/entities/annual/annual-detail.html',
                        controller: 'AnnualDetailController'
                    }
                }
            });
    });
