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

angular.module('csrsApp').controller('ContactUsersCtrl', function (Contact, $scope) {
    var self = this;

    this.users = [];
    this.fetched = false;

    $scope.$watch(function () {
        return self.contact.id;
    }, function (newValue, oldValue) {
        if (newValue) {
            Contact.users({
                id: newValue
            }, function (result) {
                self.users = result;
                self.fetched = true;
            }, function (error) {
                alert(angular.toJson(error));
            });
        }
    });
});

