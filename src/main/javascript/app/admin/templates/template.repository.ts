/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    export interface Template {
        id?: number;
        code?: string;
        text?: string;
    }

    angular.module('csrsApp').factory('templateRepository', templateRepositoryProvider);
    
    function templateRepositoryProvider (DS: JSData.DS) : JSData.DSResourceDefinition<Template> {
        'ngInject';

        return DS.defineResource({
            name: 'Template',
            endpoint: 'templates'        
        }); 
    }
}
