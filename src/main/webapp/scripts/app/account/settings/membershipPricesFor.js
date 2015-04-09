'use strict';

(function () {
    angular.module('csrsApp').factory('membershipPricesFor', membershipPricesForProvider);
    
    function membershipPricesForProvider ($q) {
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
            }]
        };

        return function membershipPricesFor (year) {
            return $q.when(prices);
        };
    };
})();
