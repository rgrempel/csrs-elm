/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.ts" />

module CSRS {
    'use strict';

    angular.module('csrsApp').directive('csrsProductVariablePicker', () => {
        return {
            scope: {
                productVariable: '=csrsProductVariablePicker',
                pricePicked: '=csrsPricePicked',
                productPicker: '=csrsParent'
            },

            templateUrl: 'scripts/components/products/product.variable.picker.html',
            controller: 'ProductVariableController',
            controllerAs: 'productVariablePicker',
            bindToController: true
        };
    });

    export class ProductVariableController {
        productValuePicked: IProductValue;
        productVariable: IProductVariable;
        productPicker: ProductController;

        constructor ($scope : angular.IScope) {
            'ngInject';

            $scope.$on('productValueSelected', (event, productValue) => {
                // console.log("productVariablePicker responding to productValueSelected");
                this.productValuePicked = productValue;
            });

            $scope.$emit('productVariableCreated', this);

            $scope.$on('$destroy', (event) => {
                $scope.$emit('productVariableDestroyed', this);
            });
        }

        getImpliedBy () {
            return this.productVariable.impliedBy;
        }

        priceForProductValue (productValue: IProductValue, showDollar : boolean) {
            return this.productPicker.priceForProductValue(productValue, showDollar);
        }
    }

    angular.module('csrsApp').controller('ProductVariableController', ProductVariableController);
}
