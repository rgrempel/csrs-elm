'use strict';

angular.module('csrsApp').directive('csrsContactFormModal', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactFormModal.html',
        controllerAs: 'contactForm',
        controller: 'ContactModalController'
    };
});

angular.module('csrsApp').controller('ContactModalController', function ($scope, Contact, $http, $state) {
    this.contact = $state.params.contact || {};
    this.serverError = null;

    this.save = function () {
        var self = this;
        self.serverError = null;

        if ($scope.editForm.$invalid) return;

        if (this.contact.id) {
            Contact.update({}, this.contact, function () {
                // Reload to see what the database actually did ...
                $scope.modalController.go('^', {}, {
                    reload: true
                });
            }, function (httpResponse) {
                self.serverError = angular.toJson(httpResponse.data);
            });
        } else {
            Contact.save({}, this.contact, function (value, headers) {
                $http.get(headers('location')).success(function (data) {
                    $scope.modalController.go('processFormsDetail', {
                        id: data.id
                    });
                }).error(function (data, status, headers, config) {
                    self.serverError = angular.toJson(data);
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
    $stateProvider.state('createContact', {
        parent: 'processForms',
        params: {
            contact: null
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/tasks/processForms/contactFormModal.html',
                controllerAs: 'contactForm',
                controller: 'ContactModalController'
            }
        }
    });
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('editContact', {
        parent: 'processFormsDetail',
        params: {
            contact: null
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/tasks/processForms/contactFormModal.html',
                controllerAs: 'contactForm',
                controller: 'ContactModalController'
            }
        }
    });
});
