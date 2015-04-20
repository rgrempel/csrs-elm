;(function () {
    'use strict';

    angular.module('csrsApp').directive('csrsProductGroup', csrsProductGroup);
    
    function csrsProductGroup () {
        return {
            scope: {
                products: '=csrsProductGroup',
                pricesPicked: '=csrsPricesPicked'
            },
            templateUrl: 'scripts/components/products/product.group.html',
            controller: 'ProductGroupController',
            controllerAs: 'productGroup',
            bindToController: true
        };
    }
})();

;(function () {
    'use strict';

    angular.module('csrsApp').controller('ProductGroupController', ProductGroupController);

    function ProductGroupController () {
        'ngInject';

    } 

    ProductGroupController.prototype = {
        headingForIndex: headingForIndex
    };

    function headingForIndex (index) {
        return String.fromCharCode(65 + index) + '.';
    }
})();
