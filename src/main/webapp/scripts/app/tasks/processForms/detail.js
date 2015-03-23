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
        $scope.$broadcast('startEditing');
    };

    this.save = function () {
        var self = this;
        Contact.update({}, self.contact, function () {
            self.load(self.contact.id);
        }, function () {
            
        });
    };

    this.cancel = function () {
        this.load($stateParams.id);
    };

    this.doDelete = function () {
        Contact.delete({id: this.contact.id}, function () {
            $state.go('processForms');
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
