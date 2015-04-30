/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.d.ts" />

module CSRS {
    angular.module('csrsApp').directive('csrsProductPicker', function csrsProductPicker () {
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
    });

    export class ProductController {
        Stream: any;
        priceFilter: IPriceFilter;
        productVariablePickers: Array<ProductVariableController>;
        product: IProduct;
        pricePicked: IProductVariantPrice;
        productVariables: Array<IProductVariable>;
        heading: string;

        constructor (Stream: any, priceFilter: IPriceFilter, $scope: angular.IScope, _: _.LoDashStatic) {
            'ngInject';
 
            this.Stream = Stream;
            this.priceFilter = priceFilter;
        
            // Keep a list of the productVariablePickers we create
            this.productVariablePickers = [];

            $scope.$on('productVariableCreated', (event, productVariablePicker) => {
                this.productVariablePickers.push(productVariablePicker);
            });

            $scope.$on('productVariableDestroyed', (event, productVariablePicker) => {
                _.pull(this.productVariablePickers, productVariablePicker);
            });

            $scope.$watchCollection(() => {
                return Stream(this.productVariablePickers).map('productValuePicked').toArray();
            }, (newValue: Array<IProductValue>) => {
                var now = Date.now();
                
                // When the collection of values picked changes, try to figure out
                // what price we've picked.
                var picked = Stream.Optional.ofNullable(this.product).map(function (product: IProduct) {
                    return Stream(product.productVariants).filter(function (variant: IProductVariant) {
                        return Stream(
                            variant.productVariantValues
                        ).map('productValue').allMatch(function (productValue: IProductValue) {
                            return Stream(newValue).anyMatch(function (pickedValue: IProductValue) {
                                return pickedValue && (pickedValue.id === productValue.id);
                            });
                        });
                    }).map('productVariantPrices').map(function (priceArray: Array<IProductVariantPrice>) {
                        return Stream(priceArray).filter(function (price: IProductVariantPrice) {
                            return now > price.validFrom;
                        }).max('validFrom').orElse(null);
                    }).toArray(); 
                }).orElse([]);

                if (picked.length === 1) {
                    this.pricePicked = picked[0];
                } else {
                    this.pricePicked = null;
                }
            });
            
            $scope.$watch(() => {
                return this.product;
            }, (newValue) => {
                this.productVariables = Stream.Optional.ofNullable(newValue).map(function (product: IProduct) {
                    return Stream(product.productVariants)
                        .flatMap('productVariantValues')
                        .map('productValue.productVariable')
                        .distinct()
                        .toArray();
                }).orElse([]);
            });
        }

        getProductCode () {
            return this.product.code;
        }

        getHeading () {
            return this.heading;
        }

        pricesForProductValue (productValue: IProductValue) {
            var Stream = this.Stream;
            var now = Date.now();

            return Stream(
                this.product.productVariants
            ).filter(function (productVariant: IProductVariant) {
                return Stream(
                    productVariant.productVariantValues
                ).map('productValue').anyMatch(function (pv: IProductValue) {
                    return pv.id === productValue.id;
                });
            }).flatMap('productVariantPrices').filter(function (price: IProductVariantPrice) {
                return now > price.validFrom;
            });
        }

        priceForProductValue (productValue: IProductValue, showDollar: boolean) {
            return this.pricesForProductValue(
                productValue
            ).max('validFrom').map((price: IProductVariantPrice) => {
                return this.priceFilter(price.priceInCents, showDollar);
            }).orElse(null);
        }
    }
    
    angular.module('csrsApp').controller('ProductController', ProductController);
}
