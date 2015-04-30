;(function () {
    'use strict';

    angular.module('csrsApp').config(HttpConfigurer);

    function HttpConfigurer ($httpProvider, httpRequestInterceptorCacheBusterProvider) {
        'ngInject';

        // Enable CSRF
        $httpProvider.defaults.xsrfCookieName = 'CSRF-TOKEN';
        $httpProvider.defaults.xsrfHeaderName = 'X-CSRF-TOKEN';

        // Cache everything except rest api requests
        httpRequestInterceptorCacheBusterProvider.setMatchlist([/.*api.*/, /.*protected.*/], true);
    }
})();
