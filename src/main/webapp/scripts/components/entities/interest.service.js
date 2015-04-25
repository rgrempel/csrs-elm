'use strict';

angular.module('csrsApp').factory('Interest', function ($resource, JSOG) {
    return $resource('api/interests/:id', {}, {
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
            method: 'PUT'
        }
    });
});
