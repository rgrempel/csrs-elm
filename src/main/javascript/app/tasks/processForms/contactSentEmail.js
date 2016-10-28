'use strict';

angular.module('csrsApp').directive('csrsContactSentEmail', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactSentEmail.html',
        scope: {
            'contact': '=csrsContactSentEmail'
        },
        controllerAs: 'sentEmailCtrl',
        bindToController: true,
        controller: 'ContactSentEmailCtrl'
    };
});

angular.module('csrsApp').controller('ContactSentEmailCtrl', function (Contact, $scope, $http, $translate) {
    var self = this;

    this.sentEmail = [];
    this.fetched = false;

    $scope.$watch(function () {
        return self.contact.id;
    }, function (newValue, oldValue) {
        if (newValue) {
            Contact.sentEmail({
                id: newValue
            }, function (result) {
                self.sentEmail = result;
                self.fetched = true;
            }, function (error) {
                alert(angular.toJson(error));
            });
        }
    });
});




