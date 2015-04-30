'use strict';

angular.module('csrsApp').controller('UserContactModalController', function ($scope, UserContact, $http, $state) {
    this.contact = $state.params.contact || {};
    this.serverError = null;

    this.save = function () {
        var self = this;
        self.serverError = null;

        $scope.editForm.$setSubmitted();
        if (!$scope.editForm.$valid) {return;}

        if (this.contact.id) {
            UserContact.update({}, this.contact, function () {
                // Reload to see what the database actually did ...
                $scope.modalController.go('^', {}, {
                    reload: true
                });
            }, function (httpResponse) {
                self.serverError = angular.toJson(httpResponse.data);
            });
        } else {
            UserContact.save({}, this.contact, function (/*value, headers*/) {
                $scope.modalController.go('^', {}, {
                    reload: true
                });
            }, function (httpResponse) {
                self.serverError = angular.toJson(httpResponse.data);
            });
        }
    };

    this.cancel = function () {
        if (this.contact.id) {
            // If we had an id, reload so that we revert the changes in the UI
            $scope.modalController.go('^', {}, {
                reload: true
            });
        } else {
            this.contact = {};
            $scope.modalController.go('^');
        }
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('createUserContact', {
        parent: 'settings',
        params: {
            contact: null
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/tasks/processForms/contactFormModal.html',
                controllerAs: 'contactForm',
                controller: 'UserContactModalController'
            }
        }
    });
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('editUserContact', {
        parent: 'settings',
        params: {
            contact: null
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/tasks/processForms/contactFormModal.html',
                controllerAs: 'contactForm',
                controller: 'UserContactModalController'
            }
        }
    });
});
