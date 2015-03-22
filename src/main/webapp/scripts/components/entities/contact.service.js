'use strict';

angular.module('csrsApp').factory('Contact', function ($resource, _) {
    return $resource('api/contacts/:id', {}, {
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
                // By default, don't send the annuals ...
                return  angular.toJson(_.omit(data, 'annuals'));
            }
        },
    
        'save': {
            method: 'POST',
            transformRequest: function (data) {
                // By default, don't send the annuals ...
                return  angular.toJson(_.omit(data, 'annuals'));
            }
        }
    });
});
