'use strict';

angular.module('csrsApp').controller('CreateAccountController', function (AccountCreationInvitation, $translate, $scope) {
    this.email = null;
    this.showSuccess = false;

    this.sendInvitation = function () {
        if (!$scope.createAccountForm.$valid) return;

        this.success = false;
        this.serverError = null;

        var self = this;
        AccountCreationInvitation.save({}, {
            email: this.email,
            langKey: $translate.use()
        }, function () {
            // Once we've built the UI for confirmation, could
            // transition state to there.
            self.success = true;
        }, function (error) {
            self.serverError = angular.toJson(error.data);
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
        },
        resolve: {
            translatePartialLoader: ['$translate', '$translatePartialLoader', function ($translate, $translatePartialLoader) {
                $translatePartialLoader.addPart('invitation');
                return $translate.refresh();
            }]
        }
    });
});
