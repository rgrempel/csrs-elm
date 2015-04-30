/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.ts" />

module CSRS {
    'use strict';

    angular.module('csrsApp').directive('csrsProductGroup', () => {
        return {
            scope: {
                productGroup: '=csrsProductGroup',
                pricesPicked: '=csrsPricesPicked'
            },
            templateUrl: 'scripts/components/products/product.group.html',
            controller: 'ProductGroupController',
            controllerAs: 'productGroupPicker',
            bindToController: true
        };
    });

    class ProductGroupController {
        productGroup : IProductGroup;
        products: Array<IProduct>;

        constructor ($scope : angular.IScope, Stream : streamjs.Stream) {
            'ngInject';

            $scope.$watch(() => {
                return this.productGroup;
            }, (newValue: IProductGroup) => {
                this.products = Stream.Optional.ofNullable(newValue).map((productGroup : IProductGroup) => {
                    // console.log("setting productGroup.products");
                    return Stream(productGroup.productGroupProducts).map<IProduct>('product').toArray();                
                }).orElse([]);
            });
            
            // When a productValue is selected, broadcast the event so that other
            // productValues which are implied can set themselves
            $scope.$on('productValueSelected', this.productValueSelectedListener);
        }
        
        headingForIndex (index : number) : string {
            return String.fromCharCode(65 + index) + '.';
        }
        
        productValueSelectedListener (event : angular.IAngularEvent, productValue : IProductValue) : void {
            event.currentScope.$broadcast('otherProductValueSelected', productValue);
        }
    }

    angular.module('csrsApp').controller('ProductGroupController', ProductGroupController);
}
