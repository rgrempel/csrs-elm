/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.ts" />

module CSRS {
    'use strict';

    angular.module('csrsApp').directive('csrsProductValuePicker', () => {
        return {
            scope: {
                productValue: '=csrsProductValuePicker',
                selected: '=csrsSelected',
                pricePicked: '=csrsPricePicked',
                readOnly: '=csrsReadOnly',
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
        readOnly: boolean;
        selected: boolean;
        
        constructor ($scope : angular.IScope, Stream: any) {
            'ngInject';

            this.scope = $scope;

            $scope.$watch(() => {
                return this.pricePicked;
            }, (newValue) => {
                // If the newValue is null, we just return ...
                if (!newValue) return;

                // console.log("productValuePicker check pricePicked to see if we're selected");

                // Otherwise, check whether we've been picked ...
                var selected = Stream(
                    newValue.productVariant.productVariantValues
                ).map('productValue').anyMatch((pv: IProductValue) => {
                    pv && (pv.id === this.productValue.id)
                });

                if (selected) this.select();
            });

            $scope.$on('otherProductValueSelected', (event : angular.IAngularEvent, otherProductValue: IProductValue) => {
                var matched : boolean = Stream(this.productValue.productValueImpliedBy).map('productValue').anyMatch((pv: IProductValue) => {
                    return pv && (pv.id === otherProductValue.id);
                });

                if (matched) this.select();
            });
        }

        select () {
            if (!this.selected) {
                this.scope.$emit('productValueSelected', this.productValue);
            }
        }

        selectClicked () {
            if (!this.readOnly) this.select();
        }
    }

    angular.module('csrsApp').controller('ProductValueController', ProductValueController);
}
