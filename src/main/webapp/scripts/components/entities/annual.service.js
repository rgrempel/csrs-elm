'use strict';

angular.module('csrsApp').factory('Annual', function ($resource) {
    return $resource('api/annuals/:id', {}, {
        'query': {
            method: 'GET',
            isArray: true
        },

        'get': {
            method: 'GET',
            transformResponse: function (data) {
                data = angular.fromJson(data);
                return data;
            }
        },

        'update': {
            method:'PUT'
        }
    });
});
