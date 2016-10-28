'use strict';

angular.module('csrsApp').directive('csrsContactUsers', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactUsers.html',
        scope: {
            'contact': '=csrsContactUsers'
        },
        controllerAs: 'usersCtrl',
        bindToController: true,
        controller: 'ContactUsersCtrl'
    };
});

angular.module('csrsApp').controller('ContactUsersCtrl', function (Contact, $scope, $http, $translate) {
    var self = this;

    this.users = [];
    this.fetched = false;
    this.showSendInvitations = false;

    $scope.$watch(function () {
        return self.contact.id;
    }, function (newValue, oldValue) {
        if (newValue) {
            Contact.users({
                id: newValue
            }, function (result) {
                self.users = result;
                self.fetched = true;
                self.showSendInvitations = result.length == 0 && self.contact.contactEmails.length > 0
            }, function (error) {
                alert(angular.toJson(error));
            });
        }
    });

    this.sendInvitation = function () {
        $http.post("/api/invitation/contacts", {
            contactIDs: [self.contact.id]
        }).success(function () {
            $translate("membership.byYear.invitationsHaveBeenSent").then(function (msg) {
                alert(msg);
            });
        }).error(function (data, status, headers, config) {
            alert(angular.toJson(data));
        });
    };
});




