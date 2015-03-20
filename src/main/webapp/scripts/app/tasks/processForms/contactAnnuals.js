'use strict';

angular.module('csrsApp').directive("csrsContactAnnuals", function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactAnnuals.html',
        scope: {
            'contact': '=csrsContactAnnuals'
        },
        controllerAs: 'annualsCtrl',
        bindToController: true,
        controller: 'ContactAnnualsCtrl'
    };
}).controller('ContactAnnualsCtrl', function (Annual, _, $http) {
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
                self.contact.annuals.push(data);
            }).error(function () {
                // Shouldn't happen ...
            });
        }, function (httpResponse) {
            // error
        });
    };

    this.deleteAnnual = function (annual) {
        var self = this;
        Annual.delete({id: annual.id}, function () {
            _.pull(self.contact.annuals, annual);
        }, function () {
            // Error
        })
    };
});
