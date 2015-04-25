;(function () {
    'use strict';

    angular.module('csrsApp').factory('JSOG', JSOGProvider);
    
    function JSOGProvider ($window) {
        'ngInject';
       
        return $window.JSOG;
    }
})();
