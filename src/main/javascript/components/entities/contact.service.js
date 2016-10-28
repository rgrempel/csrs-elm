'use strict';

angular.module('csrsApp').factory('Contact', function ($resource, _, JSOG) {
    return $resource('api/contacts/:id', {}, {
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
        
        'users': {
            method: 'GET',
            url: 'api/contacts/:id/users',
            isArray: true,
            transformResponse: function (data) {
                data = JSOG.decode(angular.fromJson(data));
                return data;
            }
        },

        'sentEmail': {
            method: 'GET',
            url: 'api/contacts/:id/email',
            isArray: true,
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
