(function () {
    'use strict';
    
    angular.module('csrsApp').factory('stream', StreamProvider);
    angular.module('csrsApp').factory('Stream', StreamProvider);

    function StreamProvider ($window) {
        'ngInject';

        return $window.Stream;
    }
})();