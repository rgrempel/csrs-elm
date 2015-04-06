'use strict';

angular.module('csrsApp').factory('Invitation', function ($resource) {
    return $resource('api/invitation/:key', {}, {
        'get': {
            method: 'GET',
            transformResponse: function (data) {
                data = JSOG.decode(angular.fromJson(data));
                return data;
            }
        }
    });
});
