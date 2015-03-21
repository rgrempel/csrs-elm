'use strict';

angular.module('csrsApp').factory('Interest', function ($resource) {
    return $resource('api/interests/:id', {}, {
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
            method: 'PUT'
        }
    });
});
