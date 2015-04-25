;(function () {
    'use strict';

    angular.module('csrsApp').directive('csrsProductPicker', csrsProductPicker);
    
    function csrsProductPicker () {
        return {
            scope: {
                product: '=csrsProductPicker',
                heading: '@csrsHeading',
                pricePicked: '=csrsPricePicked'
            },
            templateUrl: 'scripts/components/products/product.picker.html',
            controller: 'ProductController',
            controllerAs: 'productPicker',
            bindToController: true
        };
    }
})();

(function () {
    'use strict';

    angular.module('csrsApp').controller('ProductController', ProductController);

    function ProductController (Stream, priceFilter, $scope) {
        'ngInject';

        this.Stream = Stream;
        this.priceFilter = priceFilter;

        this.valuesPicked = {};
        var self = this;

        $scope.$watch('pricePicked', function (newValue /*, oldValue */) {
            // When the pricePicked changes, we want to update all of the
            // valuesPicked to match.  Unless the pricePicked is null ... that
            // is, we've decided *not* to pick a price.  In that case, we leave
            // the valuesPicked alone, so the UI is not disturbed.
            self.valuesPicked = Stream.Optional.ofNullable(newValue).map(function (picked) {
                return Stream(picked.productVariant.productVariantValues)
                    .map('productValue')
                    .groupingBy('productVariable.id');
            }).orElse(self.valuesPicked);
        });

        $scope.$watchCollection(function () {
            return self.valuesPicked;
        }, function (/*newValue, oldValue */) {
            var now = Date.now();
            
            // When the collection of valuesPicked changes, we want to figure
            // out which price we've picked, if any. If no price matches, or
            // more than one does, then we set it to null.
            var picked = Stream.Optional.ofNullable(self.product).map(function (product) {
                return Stream(product.productVariants).filter(function (variant) {
                    return Stream(
                        variant.productVariantValues
                    ).map('productValue').allMatch(function (productValue) {
                        return self.valuesPicked[productValue.productVariable.id] === productValue;
                    });
                }).map('productVariantPrices').map(function (priceArray) {
                    return Stream(priceArray).filter(function (price) {
                        return now > price.validFrom;
                    }).max('validFrom').orElse(null);
                }).toArray(); 
            }).orElse([]);

            if (picked.length === 1) {
                self.pricePicked = picked[0];
            } else {
                self.pricePicked = null;
            }
        });
    }

    /*
     * The structure of a product is like this:
     *
     *  product: {
     *      code: "product.base....",
     *      productPrereqRequires: [{
     *          requiresProduct: ...
     *      }],
     *      productPrereqRequiredBy: [{
     *          product: ...
     *      }],
     *      productVariants: [{
     *          productVariantPrices: [
     *              productVariant: ...
     *              priceInCents: ...
     *              threeYearReductionInCents: ...
     *              validFrom: milliseconds since epoch
     *          ],
     *          productVariantValues: [{
     *              productValue: {
     *                  code: 'product....',
     *                  productValueImpliedBy: [
     *                      productValue: {
     *                          ...
     *                      }
     *                  ],
     *                  productValueImplies: [{
     *                      impliesProductValue: {
     *                          ...
     *                      }
     *                  }],
     *                  productVariable: {
     *                      code: ' ... ',
     *                      productValues: [
     *                          ...
     *                      ]
     *                  }
     *              }
     *          }]
     *      }]
     *  }
     */

    ProductController.prototype = {
        getProductCode : function getProductCode () {
            return this.product.code;
        },

        getHeading : function getHeading () {
            return this.heading;
        },

        getProductVariables : function getProductVariables () {
            var Stream = this.Stream;

            var pv = Stream.Optional.ofNullable(this.product).map(function (product) {
                return product.productVariants;
            }).map(function (productVariants) {
                return Stream(productVariants)
                    .flatMap('productVariantValues')
                    .map('productValue.productVariable')
                    .distinct()
                    .toArray();
            }).orElse([]);

            return pv;
        },

        pricesForProductValue : function pricesForProductValue (productValue) {
            var Stream = this.Stream;
            var now = Date.now();

            return Stream(
                this.product.productVariants
            ).filter(function (productVariant) {
                return Stream(
                    productVariant.productVariantValues
                ).map('productValue').anyMatch(function (pv) {
                    return pv.id === productValue.id;
                });
            }).flatMap('productVariantPrices').filter(function (price) {
                return now > price.validFrom;
            });
        },

        priceForProductValue : function priceForProductValue (productValue, showDollar) {
            var self = this;

            return this.pricesForProductValue(
                productValue
            ).max('validFrom').map(function (price) {
                return self.priceFilter(price.priceInCents, showDollar);
            }).orElse(null);
        }
    };
})();
