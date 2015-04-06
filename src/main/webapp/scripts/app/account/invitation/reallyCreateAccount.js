'use strict';

angular.module('csrsApp').controller('ReallyCreateAccountController', function ($scope, $state, $translate, Register, Auth) {
    this.account = {};
    this.invitation = $state.params.invitation;
    this.email = this.invitation.userEmail.email.emailAddress;

    this.createAccount = function () {
        if (!$scope.createAccountForm.$valid) return;

        this.serverError = null;
        this.account.langKey = $translate.use();

        var self = this;
        Register.save({
            key: this.invitation.activationKey
        }, this.account, function () {
            Auth.login({
                username: self.account.login,
                password: self.account.password,
                rememberMe: false
            }).then(function () {
                $state.go('settings');
            }, function (error) {
                self.serverError = angular.toJson(error);
            });
        }, function (error) {
            self.serverError = angular.toJson(error);
        });
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('reallyCreateAccount', {
        parent: 'account',
        params: {
            invitation: null
        },
        data: {
            roles: [],
            pageTitle: 'invitation.createAccount.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/account/invitation/reallyCreateAccount.html',
                controller: 'ReallyCreateAccountController',
                controllerAs: 'reallyCreateAccountController'
            }
        }
    });
});
