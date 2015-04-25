;(function () {
    'use strict';

    angular.module('csrsApp').config(DSConfigurer);

    function DSConfigurer (DSProvider, DSHttpAdapterProvider) {
        'ngInject';

        DSProvider.defaults.basePath = '/api';

        var defaultDeserialize = DSHttpAdapterProvider.defaults.deserialize;

        DSHttpAdapterProvider.defaults.deserialize = function (resourceConfig, data) {
            var theData = data ? ('data' in data ? data.data : data) : data;
            var decoded = JSOG.decode(theData);
            return decoded;
        };
    }
})();
