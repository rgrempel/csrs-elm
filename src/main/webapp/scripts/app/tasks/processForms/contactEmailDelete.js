'use strict';

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('deleteContactEmail', {
        parent: 'processFormsDetail',
        params: {
            contact: null,
            contactEmail: null
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/tasks/processForms/contactEmailDelete.html',
                controller: 'DeleteContactEmailController',
                controllerAs: 'deleteContactEmailController'
            }
        }
    });
});

angular.module('csrsApp').controller('DeleteContactEmailController', function (ContactEmail, $scope, $state, _) {
    this.contactEmail = $state.params.contactEmail;
    this.contact = $state.params.contact;

    this.cancel = function () {
        $scope.modalController.go('^');
    };

    this.doDelete = function () {
        var self = this;
        ContactEmail.delete({id: this.contactEmail.id}, function () {
            _.pull(self.contact.contactEmails, self.contactEmail);
            $scope.modalController.go('^');
        }, function (error) {
            self.error = angular.toJson(error.data);
        });
    };
});
