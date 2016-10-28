'use strict';

angular.module('csrsApp').directive('csrsContactUsers', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactUsers.html',
        scope: {
            'contactID': '=csrsContactUsers'
        },
        controllerAs: 'usersCtrl',
        bindToController: true,
        controller: 'ContactUsersCtrl'
    };
});

angular.module('csrsApp').controller('ContactUsersCtrl', function (Contact) {
    var self = this;

    this.users = [];
    this.fetched = false;

    if (this.contactID) {
        Contact.users({
            id: this.contactID
        }, function (result) {
            self.users = result;
            self.fetched = true;
        }, function (error) {
            alert(angular.toJson(error));
        });
    }
});

