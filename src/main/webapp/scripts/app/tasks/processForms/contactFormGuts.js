'use strict';

angular.module('csrsApp').directive('csrsContactFormGuts', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactFormGuts.html',
        scope: {
            'contact': '=csrsContactFormGuts'
        },
        controllerAs: 'guts',
        bindToController: true,
        controller: 'ContactFormController'
    };
});

angular.module('csrsApp').controller('ContactFormController', function () {
    this.setOmitNaneFromDirectory = function (value) {
        this.contact.omitNameFromDirectory = value;
    };

    this.setOmitEmailFromDirectory = function (value) {
        this.contact.omitEmailFromDirectory = value;
    };
});
