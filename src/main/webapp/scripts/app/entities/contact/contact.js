'use strict';

angular.module('csrsApp')
    .config(function ($stateProvider) {
        $stateProvider
            .state('contact', {
                parent: 'entity',
                url: '/contact',
                data: {
                    roles: ['ROLE_USER'],
                    pageTitle: 'csrsApp.contact.home.title'
                },
                views: {
                    'content@': {
                        templateUrl: 'scripts/app/entities/contact/contacts.html',
                        controller: 'ContactController'
                    }
                }
            })
            .state('contactDetail', {
                parent: 'entity',
                url: '/contact/:id',
                data: {
                    roles: ['ROLE_USER'],
                    pageTitle: 'csrsApp.contact.detail.title'
                },
                views: {
                    'content@': {
                        templateUrl: 'scripts/app/entities/contact/contact-detail.html',
                        controller: 'ContactDetailController'
                    }
                }
            });
    });
