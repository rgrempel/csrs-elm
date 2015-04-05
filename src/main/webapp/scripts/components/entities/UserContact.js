'use strict';

angular.module('csrsApp').factory('UserContact', function ($resource) {
    return $resource('api/account/contacts/:id', {}, {
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
            method: 'PUT',
            transformRequest: function (data) {
                // By default, don't send the annuals or interests ...
                return angular.toJson(_.omit(data, ['annuals', 'interests']));
            }
        },
    
        'save': {
            method: 'POST',
            transformRequest: function (data) {
                // By default, don't send the annuals ...
                return angular.toJson(_.omit(data, ['annuals', 'interests']));
            }
        }
    });
});
