'use strict';

angular.module('csrsApp').factory('ContactEmail', function ($resource) {
    return $resource('api/contactEmails/:id', {}, {
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
