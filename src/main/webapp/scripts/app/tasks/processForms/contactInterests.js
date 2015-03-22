'use strict';

angular.module('csrsApp').directive('csrsContactInterests', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactInterests.html',
        scope: {
            'contact': '=csrsContactInterests'
        },
        controllerAs: 'interestsCtrl',
        bindToController: true,
        controller: 'ContactInterestsCtrl'
    };
});

angular.module('csrsApp').controller('ContactInterestsCtrl', function (Interest, _, $http) {
    this.create = function () {
        var newInterest = {
            editMode: true,
            interest: '',
            contact: {
                id: this.contact.id
            }
        };

        this.contact.interests.push(newInterest);
    };

    this.remove = function (interest) {
        var self = this;
        Interest.delete({id: interest.id}, function () {
            _.pull(self.contact.interests, interest);
        }, function () {
            // Error
        });
    };

    this.commit = function (interest) {
        // Need to massage this ... should figure out how to
        // deal with this generally. Problem is that "contact"
        // will be an integer, not an object, and the deserializaer
        // at the other end expects the object. Could either deal
        // with it at this end in the service, or at that end in
        // the deserializer.
        interest.contact = {
            id: this.contact.id
        };

        if (interest.id) {
            Interest.update({}, interest, function () {
                interest.editMode = false;
            }, function () {
                // error
            });
        } else {
            var self = this;
            Interest.save({}, interest, function (value, headers) {
                $http.get(headers('location')).success(function (data) {
                    self.contact.interests.push(data);
                    _.pull(self.contact.interests, interest);
                }).error(function () {
                    // Shouldn't happen ...
                });
            }, function () {
                // error
            });
        }
    };

    this.cancel = function (interest) {
        _.pull(this.contact.interests, interest);
    };
});
