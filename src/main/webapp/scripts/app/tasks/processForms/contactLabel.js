'use strict';

angular.module('csrsApp').directive("csrsContactLabel", function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactLabel.html',
        scope: {
            'contact': '=csrsContactLabel'
        },
        controllerAs: 'contactLabel',
        bindToController: true,
        controller: function () {
            // Empty for now
        }
    };
});
