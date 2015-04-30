'use strict';

(function () {
    angular.module('csrsApp').controller('RenewalController', RenewalController);

    angular.extend(RenewalController.prototype, {
        cancel: cancel,
        saveRenewal: saveRenewal
    });
 
    function RenewalController ($scope, $state, _, Renewal, ProductGroup) {
        'ngInject';
        
        this.scope = $scope;
        this._ = _;
        this.Renewal = Renewal;

        this.contact = $state.params.contact;

        this.products = [];
        this.pricesPicked = {};

        var self = this;

        ProductGroup.find(1).then(function (productGroup) {
            self.productGroup = productGroup;
        });

        // this.error;
        // this.prices = {
        //     membership: {},
        //     rr: {},
        //     iter: {}
        // };
        
/*        this.renewal = this.contact.renewals[0] || {
            // Default to regular membership, no subscriptions, 1 year 
            renewalItems: [{
                productVariantPrice:
            }],
            year: 2015,
            duration: 1
        };

        this.renewal.contact = {
            id: this.contact.id
        };
*/
        /*
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
        */
    }

    function cancel () {
        /* jshint validthis: true */
        this.scope.modalController.go('^', {}, {
            reload: true
        });
    }

    function saveRenewal () {
        /* jshint validthis: true */
        var self = this;

        // We pass to the database what we displayed to the user,
        // so that we can throw an error if the database disagrees
        this.renewal.priceInCents = this.price.f;

        var saver = this.renewal.id ? this.Renewal.update : this.Renewal.save;

        saver.call(this.Renewal, {}, this.renewal, function () {
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
