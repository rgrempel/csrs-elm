'use strict';

angular.module('csrsApp').controller('CreateAccountController', function (AccountCreationInvitation, $translate, $scope, $state, focus) {
    this.email = null;
    this.key = null;
    this.showSuccess = false;

    focus('email');

    this.sendInvitation = function () {
        if (!$scope.createAccountForm.$valid) {return;}

        this.success = false;
        this.serverError = null;

        var self = this;
        AccountCreationInvitation.save({}, {
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
    $stateProvider.state('createAccount', {
        parent: 'account',
        url: '/account/create',
        data: {
            roles: [],
            pageTitle: 'invitation.createAccount.title'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/account/invitation/createAccount.html',
                controller: 'CreateAccountController',
                controllerAs: 'createAccountController'
            }
        }
    });
});
