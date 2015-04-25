'use strict';

angular.module('csrsApp').factory('ContactEmail', function ($resource, JSOG) {
    return $resource('api/contactEmails/:id', {}, {
        'query': {
            method: 'GET',
            isArray: true,
            transformResponse: function (data) {
                data = JSOG.decode(angular.fromJson(data));
                return data;
            }
        },

        'get': {
            method: 'GET',
            transformResponse: function (data) {
                data = JSOG.decode(angular.fromJson(data));
                return data;
            }
        },

        'update': {
            method:'PUT'
        }
    });
});
