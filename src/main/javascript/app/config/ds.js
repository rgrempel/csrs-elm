;(function () {
    'use strict';

    angular.module('csrsApp').config(DSConfigurer);

    function DSConfigurer (DSProvider, DSHttpAdapterProvider, $windowProvider) {
        'ngInject';

        var JSOG = $windowProvider.$get().JSOG;

        DSProvider.defaults.basePath = '/api';

        DSHttpAdapterProvider.defaults.deserialize = function (resourceConfig, data) {
            var theData = data ? ('data' in data ? data.data : data) : data;
            var decoded = JSOG.decode(theData);
            return decoded;
        };
    }
})();
