'use strict';

angular.module('csrsApp')
    .config(function ($stateProvider) {
        $stateProvider
            .state('register', {
                parent: 'account',
                url: '/register',
                data: {
                    roles: [],
                    pageTitle: 'register.title'
                },
                views: {
                    'content@': {
                        templateUrl: 'scripts/app/account/register/register.html',
                        controller: 'RegisterController'
                    }
                }
            });
    });
