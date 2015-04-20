;(function () {
    'use strict';

    angular.module('csrsApp').directive('csrsProductVariablePicker', csrsProductVariablePicker);
    
    function csrsProductVariablePicker () {
        return {
            scope: {
                productPicker: '=csrsParent',
                productVariable: '=csrsProductVariablePicker',
                productValuePicked: '=csrsProductValuePicked'
            },
            templateUrl: 'scripts/components/products/product.variable.picker.html',
            controller: 'ProductVariableController',
            controllerAs: 'productVariablePicker',
            bindToController: true
        };
    }
})();

(function () {
    'use strict';

    angular.module('csrsApp').controller('ProductVariableController', ProductVariableController);

    function ProductVariableController () {
        'ngInject';

    }

    ProductVariableController.prototype = {
        selectProductValue: selectProductValue,
        isProductValueSelected: isProductValueSelected,
        priceForProductValue: priceForProductValue
    };

    function selectProductValue (productValue) {
        this.productValuePicked = productValue;
    }

    function isProductValueSelected (productValue) {
        return this.productValuePicked === productValue;
    }

    function priceForProductValue (productValue, showDollar) {
        return this.productPicker.priceForProductValue(productValue, showDollar);
    }
})();
