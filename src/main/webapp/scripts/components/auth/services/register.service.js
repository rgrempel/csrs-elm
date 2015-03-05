'use strict';

angular.module('csrsApp')
    .factory('Register', function ($resource) {
        return $resource('api/register', {}, {
        });
    });


