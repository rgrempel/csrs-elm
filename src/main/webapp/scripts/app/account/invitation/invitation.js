'use strict';

angular.module('csrsApp').controller('InvitationController', function ($state, $scope, Invitation) {
    this.key = $state.params.key;
    this.invitation = null;

    this.checkInvitation = function () {
        var self = this;
        if (this.key) {
            Invitation.get({
                key: this.key
            }, function (result) {
                self.noSuchInvitation = false;
                self.invitation = result;

                $state.go('reallyCreateAccount', {
                    invitation: result
                });
            }, function (/*error*/) {
                self.noSuchInvitation = true;
            });
        }
    };
    
    this.checkInvitation();
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('invitation', {
        parent: 'account',
        url: '/invitation/{key}',
        params: {
            key: null
        },
        data: {
            pageTitle: 'invitation.use.pageTitle'
        },
        views: {
            'content@': {
                templateUrl: 'scripts/app/account/invitation/invitation.html',
                controller: 'InvitationController',
                controllerAs: 'invitationController'
            }
        }
    });
});
