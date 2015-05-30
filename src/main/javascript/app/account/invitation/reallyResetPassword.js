'use strict';

angular.module('csrsApp').controller('ReallyResetPasswordController', function ($scope, $state, $http, Auth) {
    this.account = {};
    this.invitation = $state.params.invitation;
    this.email = this.invitation.userEmail.email.emailAddress;
    this.login = this.invitation.userEmail.user.login;

    this.resetPassword = function () {
        if (!$scope.resetPasswordForm.$valid) return;

        this.serverError = null;
        this.success = false;

        var self = this;
        $http.post('/api/reset_password', {
            key: this.invitation.activationKey,
            newPassword: this.password
        }).then(function () {
            Auth.login({
                username: self.login,
                password: self.password,
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
    $stateProvider.state('reallyResetPassword', {
        parent: 'account',
        params: {
            invitation: null
        },
        data: {
            roles: [],
            pageTitle: 'invitation.resetPassword.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/account/invitation/reallyResetPassword.html',
                controller: 'ReallyResetPasswordController',
                controllerAs: 'reallyResetPasswordController'
            }
        }
    });
});
