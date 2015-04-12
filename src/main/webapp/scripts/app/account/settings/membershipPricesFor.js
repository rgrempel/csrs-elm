'use strict';

(function () {
    angular.module('csrsApp').factory('membershipPricesFor', membershipPricesForProvider);
    
    function membershipPricesForProvider ($q, _) {
        'ngInject';

        var prices = {
            membership: [{
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
            }],
            
            rr: [{
                code: 1,
                price: 3500
            },{
                code: 2,
                price: 3000
            }],
            
            iter: [{
                code: 1,
                price: 2500
            },{
                code: 2,
                price: 1800
            }],
    
            getPrice: function getPrice (renewal) {
                /* jshint validthis: true */
                var price = {};

                var membership = _.find(this.membership, {
                    code: renewal.membership
                });

                price.a = membership.price;

                if (renewal.rr > 0) {
                    price.b = _.find(this.rr, {
                        code: membership.rrCode
                    }).price;
                } else {
                    price.b = 0;
                }

                if (renewal.iter) {
                    price.c = _.find(this.iter, {
                        code: membership.iterCode
                    }).price;
                } else {
                    price.c = 0;
                }

                price.d = price.a + price.b + price.c;

                price.e = (price.d * 3) - membership.reduction;

                price.f = renewal.duration == 1 ? price.d : price.e;

                return price;
            }
        };

        return function membershipPricesFor (year) {
            return $q.when(prices);
        };
    };
})();
