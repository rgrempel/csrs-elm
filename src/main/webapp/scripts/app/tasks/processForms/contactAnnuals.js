'use strict';

angular.module('csrsApp').directive('csrsContactAnnuals', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactAnnuals.html',
        scope: {
            'contact': '=csrsContactAnnuals'
        },
        controllerAs: 'annualsCtrl',
        bindToController: true,
        controller: 'ContactAnnualsCtrl'
    };
});

angular.module('csrsApp').controller('ContactAnnualsCtrl', function (Annual, _, $http, $state) {
    this.createAnnual = function () {
        var self = this;
        
        // Default to the current year, or the next year if there
        // is already an entry for the current year
        var thisYear = new Date().getFullYear();
        while (_.find(this.contact.annuals, {year: thisYear})) {
            thisYear += 1;
        }

        var newAnnual = {
            year: thisYear,
            membership: 2, // default to regular member
            iter: false,
            rr: 0,
            contact: {
                id: this.contact.id
            }
        };

        Annual.save({}, newAnnual, function (value, headers) {
            $http.get(headers('location')).success(function (data) {
                data.editMode = true;
                self.contact.annuals.push(data);
            }).error(function () {
                // Shouldn't happen ...
            });
        }, function () {
            // error
        });
    };

    this.confirmDelete = function (annual) {
        $state.go('deleteAnnual', {
            annual: annual,
            contact: this.contact
        });
    };

    this.edit = function (annual) {
        annual.editMode = true;
    };

    this.commit = function (annual) {
        // Need to massage this ... should figure out how to
        // deal with this generally. Problem is that "contact"
        // will be an integer, not an object, and the deserializaer
        // at the other end expects the object. Could either deal
        // with it at this end in the service, or at that end in
        // the deserializer.
        annual.contact = {
            id: this.contact.id
        };

        Annual.update({}, annual, function () {
            annual.editMode = false;
        }, function () {
            // error
        });
    };

    this.cancel = function (annual) {
        var self = this;
        Annual.get({
            id: annual.id
        }, function (result) {
            _.pull(self.contact.annuals, annual);
            self.contact.annuals.push(result);
        }, function () {

        });
    };
});
