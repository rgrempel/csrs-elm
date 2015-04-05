'use strict';

angular.module('csrsApp').controller('SettingsController', function ($scope, Principal, Auth, UserContact, $state) {
    this.account = null;
    this.contacts = [];
    this.contactsError = null;
    this.gotContacts = false;
    this.newContact = {};
    this.newContactError = null;

    this.loadContacts = function () {
        var self = this;
        Principal.identity().then(function(account) {
            self.account = account;

            UserContact.query({}, function (result) {
                self.contacts = result;
                self.contactsError = null;
                self.gotContacts = true;
            }, function (error) {
                self.contacts = [];
                self.contactsError = angular.toJson(error.data);
                self.gotContacts = false;
            });
        });
    };

    this.loadContacts();

    this.saveNewContact = function () {
        if (!$scope.newContactForm.$valid) return;

        var self = this;
        UserContact.save({}, this.newContact, function () {
            self.newContactError = null;
            self.loadContacts();
        }, function (error) {
            self.newContactError = angular.toJson(error.data);
        });
    };

    this.startEditing = function (contact) {
        $state.go('editUserContact', {
            contact: contact
        });
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('settings', {
        parent: 'account',
        url: '/settings',
        data: {
            roles: ['ROLE_USER'],
            pageTitle: 'global.menu.account.settings'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/account/settings/settings.html',
                controller: 'SettingsController',
                controllerAs: 'settingsController'
            }
        }
    });
});
