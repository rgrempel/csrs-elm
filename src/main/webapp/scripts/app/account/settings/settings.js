'use strict';

(function () {
    angular.module('csrsApp').controller('SettingsController', SettingsController);
            
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

    SettingsController.prototype = {
        loadContacts: loadContacts,
        saveNewContact: saveNewContact,
        startEditing: startEditing,
        renew: renew
    };

    function SettingsController ($scope, Principal, Auth, UserContact, $state) {
        'ngInject';

        this.account = null;
        this.contacts = [];
        this.contactsError = null;
        this.gotContacts = false;
        this.newContact = {};
        this.newContactError = null;
            
        this.Principal = Principal;
        this.scope = $scope;
        this.Auth = Auth;
        this.UserContact = UserContact;
        this.state = $state;

        this.loadContacts();
    }

    function loadContacts () {
        var self = this;
        this.Principal.identity().then(function(account) {
            self.account = account;

            self.UserContact.query({}, function (result) {
                self.contacts = result;
                self.contactsError = null;
                self.gotContacts = true;
            }, function (error) {
                self.contacts = [];
                self.contactsError = angular.toJson(error.data);
                self.gotContacts = false;
            });
        });
    }

    function saveNewContact () {
        if (!this.scope.newContactForm.$valid) return;

        var self = this;
        this.UserContact.save({}, this.newContact, function () {
            self.newContactError = null;
            self.loadContacts();
        }, function (error) {
            self.newContactError = angular.toJson(error.data);
        });
    }

    function startEditing (contact) {
        this.state.go('editUserContact', {
            contact: contact
        });
    }

    function renew (contact) {
        this.state.go('renewal', {
            contact: contact
        });
    }
})();
