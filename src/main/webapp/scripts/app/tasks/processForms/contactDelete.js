'use strict';

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('deleteContact', {
        parent: 'processFormsDetail',
        params: {
            contact: null
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/tasks/processForms/contactDelete.html',
                controller: 'DeleteContactController',
                controllerAs: 'deleteContactController'
            }
        }
    });
});

angular.module('csrsApp').controller('DeleteContactController', function (Contact, $scope, $state) {
    this.contact = $state.params.contact;
    this.error = null;

    this.cancel = function () {
        $scope.modalController.go('^');
    };

    this.doDelete = function () {
        this.error = null;
        var self = this;
        Contact.delete({id: this.contact.id}, function () {
            $scope.modalController.go('processForms');
        }, function (error) {
            self.error = angular.toJson(error.data);
        });
    };
});
