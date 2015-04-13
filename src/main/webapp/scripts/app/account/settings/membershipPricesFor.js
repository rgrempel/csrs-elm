'use strict';

(function () {
    angular.module('csrsApp').factory('membershipPricesFor', membershipPricesForProvider);
    
    function membershipPricesForProvider ($q, _, Product) {
        'ngInject';

        return function membershipPricesFor (year) {
            return Product.query().$promise.then(function (productList) {
                return new MembershipPrices(productList, _);
            });
        };
    }

    angular.extend(MembershipPrices.prototype, {
        getPrice: getPrice
    });

    function MembershipPrices (productList, _) {
        this._ = _;

        var self = this;

        // Adapt from the productList to something that is more fluent
        angular.forEach(productList, function (product) {
            self[product.code] = _.map(product.productCategories, function (productCategory) {
                var category = {
                    code: productCategory.code,
                    price: productCategory.productCategoryPrices[0].priceInCents,
                    reduction: productCategory.productCategoryPrices[0].threeYearReductionInCents
                };

                angular.forEach(productCategory.productCategoriesImplies, function (productCategoryImplies) {
                    category[productCategoryImplies.impliesProductCategory.product.code + 'Code'] = productCategoryImplies.impliesProductCategory.code;
                });

                return category;
            });
        });
    }
    
    function getPrice (renewal) {
        /* jshint validthis: true */
        var price = {};

        var membership = this._.find(this.membership, {
            code: renewal.membership
        });

        price.a = membership.price;

        if (renewal.rr > 0) {
            price.b = this._.find(this.rr, {
                code: membership.rrCode
            }).price;
        } else {
            price.b = 0;
        }

        if (renewal.iter) {
            price.c = this._.find(this.iter, {
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
})();
