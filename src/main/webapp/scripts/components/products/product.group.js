;(function () {
    'use strict';

    angular.module('csrsApp').directive('csrsProductGroup', csrsProductGroup);
    
    function csrsProductGroup () {
        return {
            scope: {
                productGroup: '=csrsProductGroup',
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

    function ProductGroupController ($scope, Stream) {
        'ngInject';

        var self = this;
        $scope.$watch(function () {
            return self.productGroup;
        }, function (newValue, oldValue) {
            self.products = Stream.Optional.ofNullable(newValue).map(function (productGroup) {
                return Stream(productGroup.productGroupProducts).map('product').toArray();                
            }).orElse([]); 
        });
    }

    ProductGroupController.prototype = {
        headingForIndex: headingForIndex
    };

    function headingForIndex (index) {
        return String.fromCharCode(65 + index) + '.';
    }
})();
