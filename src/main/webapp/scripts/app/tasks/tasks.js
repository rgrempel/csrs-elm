'use strict';

angular.module('csrsApp')
    .config(function ($stateProvider) {
        $stateProvider
            .state('tasks', {
                abstract: true,
                parent: 'site'
            });
    });
