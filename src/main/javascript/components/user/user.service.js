'use strict';

angular.module('csrsApp').factory('User', function ($resource, JSOG) {
    return $resource('api/users/:login', {}, {
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

        'head': {
            method: 'HEAD'
        }
    });
});
