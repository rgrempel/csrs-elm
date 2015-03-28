'use strict';

angular.module('csrsApp').factory('AccountCreationInvitation', function ($resource) {
    return $resource('api/invitation/account', {}, {
    
    });
});


