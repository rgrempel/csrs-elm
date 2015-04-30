/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.d.ts" />

module CSRS {
    angular.module('csrsApp').directive('csrsProductValuePicker', function csrsProductValuePicker () {
        return {
            scope: {
                productValue: '=csrsProductValuePicker',
                selected: '=csrsSelected',
                pricePicked: '=csrsPricePicked',
                price: '@csrsPrice'
            },

            templateUrl: 'scripts/components/products/product.value.picker.html',
            controller: 'ProductValueController',
            controllerAs: 'productValuePicker',
            bindToController: true
        };
    });
    
    class ProductValueController {
        scope: angular.IScope;
        pricePicked: IProductVariantPrice;
        productValue: IProductValue;

        constructor ($scope : angular.IScope, Stream: any) {
            'ngInject';

            this.scope = $scope;

            $scope.$watch(() => {
                return this.pricePicked;
            }, (newValue) => {
                // If the newValue is null, we just return ...
                if (!newValue) return;

                // Otherwise, check whether we've been picked ...
                var selected = Stream(
                    newValue.productVariant.productVariantValues
                ).map('productValue').anyMatch(function (pv: IProductValue) {
                    pv.id === this.productValue.id
                });

                if (selected) this.select();
            });

            $scope.$on('otherProductValueSelected', (event : angular.IAngularEvent, productValue: IProductValue) => {
                var matched : boolean = Stream(this.productValue.productValueImpliedBy).map('productValue').anyMatch(function (pv: IProductValue) {
                    return pv.id === productValue.id;
                });

                if (matched) this.select();
            });
        }

        select () {
            this.scope.$emit('productValueSelected', this.productValue);
        }
    }

    angular.module('csrsApp').controller('ProductValueController', ProductValueController);
}
