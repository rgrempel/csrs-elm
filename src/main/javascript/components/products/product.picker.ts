/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.ts" />

module CSRS {
    'use strict';

    angular.module('csrsApp').directive('csrsProductPicker', () => {
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
        Stream: streamjs.Stream;
        priceFilter: IPriceFilter;
        productVariablePickers: Array<ProductVariableController>;
        product: IProduct;
        pricePicked: IProductVariantPrice;
        productVariables: Array<IProductVariable>;
        heading: string;

        constructor (Stream: streamjs.Stream, priceFilter: IPriceFilter, $scope: angular.IScope, _: _.LoDashStatic) {
            'ngInject';
 
            this.Stream = Stream;
            this.priceFilter = priceFilter;
        
            // Keep a list of the productVariablePickers we create
            this.productVariablePickers = [];

            $scope.$on('productVariableCreated', (event, productVariablePicker) => {
                // console.log("productController: producVariableCreated");
                this.productVariablePickers.push(productVariablePicker);
            });

            $scope.$on('productVariableDestroyed', (event, productVariablePicker) => {
                // console.log("productController: producVariableDestroyed");
                _.pull(this.productVariablePickers, productVariablePicker);
            });

            $scope.$watchCollection(() => {
                return Stream(this.productVariablePickers).map('productValuePicked').toArray();
            }, (newValue: Array<IProductValue>) => {
                this.handleProductValuesPicked(newValue);
            });
            
            $scope.$watch(() => {
                return this.product;
            }, (newValue) => {
                // console.log("productPicker: setting product");

                this.productVariables = Stream.Optional.ofNullable(newValue).map((product: IProduct) => {
                    return Stream(product.productVariants)
                        .flatMap<IProductVariantValue>('productVariantValues')
                        .map<IProductVariable>('productValue.productVariable')
                        .distinct()
                        .toArray();
                }).orElse([]);
            });
        }

        getProductCode () : string {
            return this.product.code;
        }

        getHeading () : string {
            return this.heading;
        }

        pricesForProductValue (productValue: IProductValue) : streamjs.Pipeline<IProductVariantPrice> {
            var Stream = this.Stream;
            var now = Date.now();

            return Stream(
                this.product.productVariants
            ).filter((productVariant: IProductVariant) => {
                return Stream(
                    productVariant.productVariantValues
                ).map<IProductValue>(
                    'productValue'
                ).anyMatch((pv: IProductValue) => {
                    return pv.id === productValue.id;
                });
            }).flatMap<IProductVariantPrice>(
                'productVariantPrices'
            ).filter((price: IProductVariantPrice) => {
                return now > price.validFrom;
            });
        }

        priceForProductValue (productValue: IProductValue, showDollar: boolean) : string {
            // console.log("productPicker.priceForProductValue");

            return this.pricesForProductValue(
                productValue
            ).max('validFrom').map((price: IProductVariantPrice) => {
                return this.priceFilter(price.priceInCents, showDollar);
            }).orElse(null);
        }

        handleProductValuesPicked (newValue: Array<IProductValue>) : void {
            var now = Date.now();
            
            // console.log("productPicker.settingPricePicked from values picked");

            // When the collection of values picked changes, try to figure out
            // what price we've picked.
            var picked = this.Stream.Optional.ofNullable(this.product).map((product: IProduct) => {
                return this.Stream(product.productVariants).filter((variant: IProductVariant) => {
                    return this.Stream(
                        variant.productVariantValues
                    ).map('productValue').allMatch((productValue: IProductValue) => {
                        return this.Stream(newValue).anyMatch((pickedValue: IProductValue) => {
                            return pickedValue && (pickedValue.id === productValue.id);
                        });
                    });
                }).map('productVariantPrices').map((priceArray: Array<IProductVariantPrice>) => {
                    return this.Stream(priceArray).filter((price: IProductVariantPrice) => {
                        return now > price.validFrom;
                    }).max('validFrom').orElse(null);
                }).toArray(); 
            }).orElse([]);

            if (picked.length === 1) {
                this.pricePicked = picked[0];
            } else {
                this.pricePicked = null;
            }
        }
    }
    
    angular.module('csrsApp').controller('ProductController', ProductController);
}
