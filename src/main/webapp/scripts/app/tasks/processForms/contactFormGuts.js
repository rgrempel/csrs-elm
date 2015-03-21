'use strict';

angular.module('csrsApp').directive("csrsContactFormGuts", function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactFormGuts.html',
        scope: {
            'contact': '=csrsContactFormGuts'
        },
        controllerAs: 'guts',
        bindToController: true,
        controller: function () {
            // Empty for now
        }
    };
});
