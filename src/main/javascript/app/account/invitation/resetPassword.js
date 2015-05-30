'use strict';

angular.module('csrsApp').controller('ResetPasswordController', function (AccountCreationInvitation, $translate, $scope, $state, focus) {
    this.email = null;
    this.key = null;
    this.success = false;

    focus('email');

    this.sendInvitation = function () {
        if (!$scope.resetPasswordForm.$valid) return;

        this.success = false;
        this.serverError = null;

        var self = this;
        AccountCreationInvitation.save({
            passwordReset: true
        },{
            email: this.email,
            langKey: $translate.use()
        }, function () {
            self.success = true;
            focus('key');
        }, function (error) {
            self.serverError = angular.toJson(error.data);
        });
    };

    this.checkInvitation = function () {
        if (!$scope.useInvitationForm.$valid) {return;}

        $state.go('invitation', {
            key: this.key
        });
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('password-reset', {
        parent: 'account',
        url: '/password-reset',
        data: {
            roles: [],
            pageTitle: 'invitation.resetPassword.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/account/invitation/resetPassword.html',
                controller: 'ResetPasswordController',
                controllerAs: 'resetPasswordController'
            }
        }
    });
});
