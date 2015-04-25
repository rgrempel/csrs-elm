(function () {
    'use strict';

    angular.module('csrsApp').filter('price', priceFilterProvider);

    function priceFilterProvider (currencyFilter) {
        'ngInject';

        return function priceFilter (price, useDollarSign) {
            // Make it default to true if undefined
            if (useDollarSign === undefined) {
                useDollarSign = true;
            }

            var precision = (price % 100 === 0) ? 0 : 2;
            var prefix = useDollarSign ? '$' : ' ';
            
            return currencyFilter(price / 100, prefix, precision);
        };
    }
})();
