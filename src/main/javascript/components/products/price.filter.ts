/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.ts" />

module CSRS {
    'use strict';

    export interface IPriceFilter {
        (price: number, useDollarSign: boolean) : string;
    }

    angular.module('csrsApp').filter('price', function (currencyFilter : Function) : IPriceFilter {
        'ngInject';

        return function priceFilter (price : number, useDollarSign : boolean) : string {
            // Make it default to true if undefined
            if (useDollarSign === undefined) {
                useDollarSign = true;
            }

            var precision = (price % 100 === 0) ? 0 : 2;
            var prefix = useDollarSign ? '$' : ' ';
            
            return currencyFilter(price / 100, prefix, precision);
        };
    });
}
