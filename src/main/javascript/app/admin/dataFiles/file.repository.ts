/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    export interface DataFile {
        id: number;
        path: string;
        contentType: string;
        size: number;
    }

    angular.module('csrsApp').factory('dataFileRepository', function (DS: JSData.DS) : JSData.DSResourceDefinition<DataFile> {
        'ngInject';

        return DS.defineResource<DataFile>({
            name: 'DataFile',
            endpoint: 'files'        
        }); 
    });
}
