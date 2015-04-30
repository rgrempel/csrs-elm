;(function () {
    'use strict';

    angular.module('csrsApp').factory('ProductGroup', ProductGroupProvider);
    
    function ProductGroupProvider (DS) {
        'ngInject';

        return DS.defineResource({
            name: 'ProductGroup',
            endpoint: 'product-groups'        
        }); 
    }
})();
