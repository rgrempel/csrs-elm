'use strict';

angular.module('csrsApp').controller('RenewalController', function ($scope, $state, _) {
    this.contact = $state.params.contact;
    this.error = null;
    
    this.renewal = {
        membership: 2,
        iter: false,
        rr: 0
    };

    this.membershipOptions = [{
        code: 1,
        rrCode: 1,
        iterCode: 1,
        price: 10000,
        reduction: 1500
    },{
        code: 2,
        rrCode: 1,
        iterCode: 1,
        price: 4000,
        reduction: 3000
    },{
        code: 3,
        rrCode: 1,
        iterCode: 1,
        price: 2000,
        reduction: 1500
    },{
        code: 4,
        rrCode: 2,
        iterCode: 2,
        price: 2000,
        reduction: 1500
    },{
        code: 5,
        rrCode: 2,
        iterCode: 2,
        price: 2000,
        reduction: 1500
    }];

    this.rrOptions = [{
        code: 1,
        price: 3500
    },{
        code: 2,
        price: 3000
    }];

    this.iterOptions = [{
        code: 1,
        price: 2500
    },{
        code: 2,
        price: 1800
    }];

    this.price = {
        a: 0,
        b: 0,
        c: 0,
        d: 0,
        e: 0
    };

    var self = this;
    $scope.$watch(function () {
        return self.renewal;
    }, function (newValue) {
        var membership = _.find(self.membershipOptions, {
            code: self.renewal.membership
        });

        self.price.a = membership.price;

        if (self.renewal.rr > 0) {
            self.price.b = _.find(self.rrOptions, {
                code: membership.rrCode
            }).price;
        } else {
            self.price.b = 0;
        }

        if (self.renewal.iter) {
            self.price.c = _.find(self.iterOptions, {
                code: membership.iterCode
            }).price;
        } else {
            self.price.c = 0;
        }

        self.price.d = self.price.a + self.price.b + self.price.c;

        self.price.e = (self.price.d * 3) - membership.reduction;
    }, true);

    this.loadRenewal = function () {
        var self = this;

        UserContact.query({}, function (result) {
            self.contacts = result;
            self.contactsError = null;
            self.gotContacts = true;
        }, function (error) {
            self.contacts = [];
            self.contactsError = angular.toJson(error.data);
            self.gotContacts = false;
        });
    };

    // this.loadRenewal();

    this.renewForOneYear = function () {

    };

    this.renewForThreeYears = function () {

    };

    this.cancel = function () {
        $scope.modalController.go('^');
    };

    this.saveRenewal = function () {
        var self = this;
        Renewal.save({}, this.renewal, function () {
            self.error = null;
        }, function (error) {
            self.error = angular.toJson(error.data);
        });
    };
});

angular.module('csrsApp').config(function ($stateProvider) {
    $stateProvider.state('renewal', {
        parent: 'settings',
        params: {
            contact: null
        },
        data: {
            roles: ['ROLE_USER'],
        },
        views: {
            'modal@': {
                templateUrl: 'scripts/app/account/settings/renewal.html',
                controller: 'RenewalController',
                controllerAs: 'renewalForm'
            }
        }
    });
});
