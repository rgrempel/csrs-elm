/// <reference path="../../types/tsd.d.ts" />
/// <reference path="../../types/app.d.ts" />

module CSRS {
    angular.module('csrsApp').directive('csrsProductVariablePicker', function csrsProductVariablePicker () {
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
