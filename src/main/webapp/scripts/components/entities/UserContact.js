'use strict';

angular.module('csrsApp').factory('UserContact', function ($resource, _) {
    return $resource('api/account/contacts/:id', {}, {
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
            method: 'PUT',
            transformRequest: function (data) {
                // By default, don't send the annuals or interests ...
                return angular.toJson(_.omit(data, ['annuals', 'interests', 'contactEmails']));
            }
        },
    
        'save': {
            method: 'POST',
            transformRequest: function (data) {
                // By default, don't send the annuals ...
                return angular.toJson(_.omit(data, ['annuals', 'interests', 'contactEmails']));
            }
        }
    });
});
