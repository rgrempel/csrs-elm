'use strict';

angular.module('csrsApp')
    .config(function ($stateProvider) {
        $stateProvider
            .state('password', {
                parent: 'account',
                url: '/password',
                data: {
                    roles: ['ROLE_USER'],
                    pageTitle: 'global.menu.account.password'
                },
                views: {
                    'content@': {
                        templateUrl: 'scripts/app/account/password/password.html',
                        controller: 'PasswordController',
                        controllerAs: 'passwordController'
                    }
                }
            });
    });

angular.module('csrsApp')
    .controller('PasswordController', function ($scope, Auth, Principal) {
        var self = this;

        Principal.identity().then(function (account) {
            self.account = account;
        });

        this.changePassword = function () {
            if (!$scope.changePasswordForm.$valid) return;
            
            this.showSuccess = false;
            this.passwordFailed = false;
            this.serverError = null;

            Auth.changePassword(this.currentPassword, this.newPassword).then(function () {
                self.showSuccess = true;
            }, function (error) {
                if (error.status === 403) {
                    self.passwordFailed = true;
                } else {
                    self.serverError = angular.toJson(error);
                }
            });
        };
    });
