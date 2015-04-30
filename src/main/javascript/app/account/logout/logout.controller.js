'use strict';

angular.module('csrsApp')
    .controller('LogoutController', function (Auth) {
        Auth.logout();
    });
