'use strict';

angular.module('csrsApp').controller('ProcessFormsDetailController', function (
    $scope, 
    $stateParams, 
    Contact, 
    Annual, 
    _, 
    $http, 
    $window
) { 
    this.contact = {};

    this.load = function (id) {
        var self = this;
        Contact.get({
            id: id,
            withAnnuals: true
        }, function(result) {
            self.contact = result;
            $('#saveContactModal').modal('hide');
        }, function(error) {
            
        });
    };

    this.load($stateParams.id);

    this.startEditing = function () {
        $('#saveContactModal').modal('show');
    };

    this.save = function () {
        var self = this;
        Contact.update({}, self.contact, function () {
            self.load(self.contact.id);
        }, function (error) {
            
        });
    };

    this.cancel = function () {
        this.load($stateParams.id);
    };

    this.doDelete = function (id) {
        $window.alert("bob " + id);
//        Contact.delete({id: contact.id}, function () {
            // Change state ...
  //      });
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('processFormsDetail', {
        parent: 'processForms',
        url: '/processForms/contact/:id',
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
