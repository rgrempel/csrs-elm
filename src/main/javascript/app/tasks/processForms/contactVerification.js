'use strict';

angular.module('csrsApp').directive('csrsContactVerification', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactVerification.html',
        scope: {
            'contact': '=csrsContactVerification',
            'reload': '&'
        },
        controllerAs: 'verificationCtrl',
        bindToController: true,
        controller: 'ContactVerificationController'
    };
});

angular.module('csrsApp').controller('ContactVerificationController', ContactVerificationController);

function ContactVerificationController (UserContact) {
    'ngInject';

    this.UserContact = UserContact;
}

ContactVerificationController.prototype = {
    markVerified: function () {
        var self = this;

        this.UserContact.markVerified({id: this.contact.id}, {},
            function () {
                self.reload();
            },

            function (error) {

            }
        );
    },

    show: function () {
        // 180 days
        return (Date.now() - this.contact.lastVerified) >
               (180 * 24 * 60 * 60 * 1000);
    }
};
