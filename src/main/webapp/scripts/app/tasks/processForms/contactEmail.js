'use strict';

angular.module('csrsApp').directive('csrsContactEmail', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactEmail.html',
        scope: {
            'contact': '=csrsContactEmail'
        },
        controllerAs: 'emailCtrl',
        bindToController: true,
        controller: 'ContactEmailCtrl'
    };
});

angular.module('csrsApp').controller('ContactEmailCtrl', function (_, $http, ContactEmail, $scope, $state) {
    this.error = null; 
    this.newAddress = null;

    this.create = function () {
        this.editMode = true;
    };

    this.confirmDelete = function (contactEmail) {
        $state.go('deleteContactEmail', {
            contactEmail: contactEmail,
            contact: this.contact
        });
    };
    
    this.commit = function () {
        if (!$scope.newEmailForm.$valid) {return;}

        // This is special-cased -- we send up a contactId
        // and an emailAddress to create ...
        var newContactEmail = {
            contact: {
                id: this.contact.id
            },
            email: {
                emailAddress: this.newAddress
            }
        };
        
        var self = this;
        
        ContactEmail.save({}, newContactEmail, function (value, headers) {
            $http.get(headers('location')).success(function (data) {
                self.contact.contactEmails.push(data);
                self.error = null;
                self.editMode = false;
            }).error(function (error) {
                self.error = angular.toJson(error.data);
            });
        }, function (error) {
            self.error = angular.toJson(error.data);
        });
    };

    this.cancel = function () {
        this.editMode = false;
        this.newAddress = null;
    };
});
