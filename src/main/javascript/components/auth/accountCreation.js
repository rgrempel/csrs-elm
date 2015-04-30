'use strict';

angular.module('csrsApp').factory('AccountCreationInvitation', function ($resource) {
    return $resource('api/invitation/account', {}, {
    
    });
});

angular.module('csrsApp').directive('csrsUniqueLogin', function (User, $q) {
    return {
        require: 'ngModel',
        
        link: function (scope, elm, attrs, ctrl) {
            ctrl.$asyncValidators.uniqueLogin = function (modelValue /*, viewValue */) {
                if (ctrl.$isEmpty(modelValue)) {
                    // consider empty model valid
                    return $q.when(true);
                } else {
                    return User.head({
                        login: modelValue
                    }).$promise.then(function () {
                        // Reverse the sense, because we fail if it's found
                        return $q.reject('already exists');
                    }, function () {
                        return $q.when(true);
                    });
                }
            };
        }
    };
});
