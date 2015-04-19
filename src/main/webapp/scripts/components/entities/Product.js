'use strict';

angular.module('csrsApp').factory('Product', function ($resource) {
    return $resource('api/prices/:id', {}, {
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