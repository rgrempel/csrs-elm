'use strict';

angular.module('csrsApp').controller('ProcessFormsDetailController', function ($scope, $state, $stateParams, Contact) { 
    this.contact = {};

    this.load = function (id) {
        var self = this;
        Contact.get({
            id: id,
            withAnnualsAndInterests: true
        }, function(result) {
            self.contact = result;
        }, function() {
            
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
        },
        resolve: {
            translatePartialLoader: ['$translate', '$translatePartialLoader', function ($translate, $translatePartialLoader) {
                $translatePartialLoader.addPart('processForms');
                $translatePartialLoader.addPart('contact');
                $translatePartialLoader.addPart('annual');
                $translatePartialLoader.addPart('global');
                return $translate.refresh();
            }]
        }
    });
});
