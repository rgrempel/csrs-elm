'use strict';

angular.module('csrsApp').controller('ProcessFormsDetailController', function ($scope, $state, $stateParams, Contact) { 
    this.contact = {};
    this.error = null;

    this.load = function (id) {
        var self = this;
        Contact.get({
            id: id,
            withAnnualsAndInterests: true
        }, function(result) {
            self.error = null;
            self.contact = result;
        }, function(error) {
            self.error = angular.toJson(error.data);
        });
    };

    this.load($stateParams.id);

    this.startEditing = function () {
        $state.go('editContact', {
            contact: this.contact
        });
    };

    this.confirmDelete = function () {
        $state.go('deleteContact', {
            contact: this.contact
        });
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('processFormsDetail', {
        parent: 'tasks',
        url: '/process-forms/contact/:id',
        data: {
            roles: ['ROLE_ADMIN'],
            pageTitle: 'csrsApp.processForms.detail.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/tasks/processForms/detail.html',
                controller: 'ProcessFormsDetailController',
                controllerAs: 'detail'
            }
        }
    });
});
