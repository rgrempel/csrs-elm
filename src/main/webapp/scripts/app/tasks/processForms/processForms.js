'use strict';

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('processForms', {
        parent: 'tasks',
        url: '/process-forms',
        data: {
            roles: ['ROLE_ADMIN'],
            pageTitle: 'csrsApp.processForms.home.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/tasks/processForms/processForms.html',
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
    /*
            .state('processFormsDetail', {
                parent: 'tasks',
                url: '/process-forms/:id',
                data: {
                    roles: ['ROLE_ADMIN'],
                    pageTitle: 'csrsApp.processForms.detail.title'
                },
                views: {
                    'content@': {
                        templateUrl: 'scripts/app/tasks/processForms/processForms-detail.html',
                        controller: 'ContactDetailController'
                    }
                },
                resolve: {
                    translatePartialLoader: ['$translate', '$translatePartialLoader', function ($translate, $translatePartialLoader) {
                        $translatePartialLoader.addPart('processForms');
                        return $translate.refresh();
                    }]
                }
            });
    });*/
