/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.d.ts" />

module CSRS {
    angular.module('csrsApp').directive('csrsProductGroup', function csrsProductGroup () {
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

        constructor ($scope : angular.IScope, Stream : any) {
            'ngInject';

            $scope.$watch(() => {
                return this.productGroup;
            }, (newValue) => {
                this.products = Stream.Optional.ofNullable(newValue).map(function (productGroup : IProductGroup) {
                    return Stream(productGroup.productGroupProducts).map('product').toArray();                
                }).orElse([]);    
            });
            
            // When a productValue is selected, broadcast the event so that other
            // productValues which are implied can set themselves
            $scope.$on('productValueSelected', this.productValueSelectedListener);
        }
        
        headingForIndex (index : number) {
            return String.fromCharCode(65 + index) + '.';
        }
        
        productValueSelectedListener (event : angular.IAngularEvent, productValue : IProductValue) {
            event.currentScope.$broadcast('otherProductValueSelected', productValue);
        }
    }

    angular.module('csrsApp').controller('ProductGroupController', ProductGroupController);
}
