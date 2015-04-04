'use strict';

angular.module('csrsApp').controller('SettingsController', function ($scope, Principal, Auth) {
    $scope.success = null;
    $scope.error = null;
    Principal.identity().then(function(account) {
        $scope.settingsAccount = account;
    });

    $scope.save = function () {
        Auth.updateAccount($scope.settingsAccount).then(function() {
            $scope.error = null;
            $scope.success = 'OK';
            Principal.identity().then(function(account) {
                $scope.settingsAccount = account;
            });
        }).catch(function() {
            $scope.success = null;
            $scope.error = 'ERROR';
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
                controller: 'SettingsController'
            }
        }
    });
});
