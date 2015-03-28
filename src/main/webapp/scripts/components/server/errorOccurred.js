'use strict';

angular.module('csrsApp').directive('csrsErrorOccurred', function () {
    return {
        templateUrl: 'scripts/components/server/errorOccurred.html',
        scope: {
            csrsErrorOccurred: '='
        }
    };
});
