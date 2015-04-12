'use strict';

(function () {
    angular.module('csrsApp').controller('RenewalController', RenewalController);

    angular.extend(RenewalController.prototype, {
        cancel: cancel,
        saveRenewal: saveRenewal
    });
 
    function RenewalController ($scope, $state, _, membershipPricesFor, Renewal) {
        'ngInject';
        
        this.scope = $scope;
        this._ = _;
        this.Renewal = Renewal;

        this.contact = $state.params.contact;

        // this.error;
        // this.prices = {
        //     membership: {},
        //     rr: {},
        //     iter: {}
        // };
        
        this.renewal = {
            membership: 2,
            iter: false,
            rr: 0,
            year: 2015,
            duration: 1,
            contact: {
                id: this.contact.id
            }
        };

        this.price = {
            a: 0,
            b: 0,
            c: 0,
            d: 0,
            e: 0,
            f: 0
        };
   
        var self = this;
        membershipPricesFor(2015).then(function (prices) {
            self.prices = prices;
            
            $scope.$watch(function () {
                return self.renewal;
            }, function () {
                self.price = self.prices.getPrice(self.renewal);
            }, true);
        });
    }

    function cancel () {
        /* jshint validthis: true */
        this.scope.modalController.go('^');
    }

    function saveRenewal () {
        /* jshint validthis: true */
        var self = this;

        // We pass to the database what we displayed to the user,
        // so that we can throw an error if the database disagrees
        this.renewal.priceInCents = this.price.f;

        this.Renewal.save({}, this.renewal, function () {
            self.error = null;
            self.scope.modalController.go('^');
        }, function (error) {
            self.error = angular.toJson(error.data);
        });
    }
})();

(function () {
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
})();
