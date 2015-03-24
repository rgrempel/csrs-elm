'use strict';

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('deleteAnnual', {
        parent: 'processFormsDetail',
        params: {
            contact: null,
            annual: null
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/tasks/processForms/annualDelete.html',
                controller: 'DeleteAnnualController',
                controllerAs: 'deleteAnnualController'
            }
        }
    });
});

angular.module('csrsApp').controller('DeleteAnnualController', function (Annual, $scope, $state, _) {
    this.annual = $state.params.annual;
    this.contact = $state.params.contact;

    this.cancel = function () {
        $scope.modalController.go('^');
    };

    this.doDelete = function () {
        var self = this;
        Annual.delete({id: this.annual.id}, function () {
            _.pull(self.contact.annuals, self.annual);
            $scope.modalController.go('^');
        }, function () {
            // Error
        });
    };
});
