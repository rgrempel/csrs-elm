/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    interface DataFileListScope extends angular.IScope {
        editForm: angular.IFormController;
    }
    
    class DataFileListController {
        files: Array<DataFile>;
        uploads: Array<any>;
        uploader: any;
        jsog: JSOG;
        serverError: string;
        scope: DataFileListScope;
        dataFileRepository: JSData.DSResourceDefinition<DataFile>;
        loDash: _.LoDashStatic

        constructor (
            dataFileRepository: JSData.DSResourceDefinition<DataFile>, 
            $scope: DataFileListScope, 
            Upload: any, 
            JSOG: JSOG,
            _: _.LoDashStatic
        ) {
            'ngInject';

            this.uploader = Upload;

            this.serverError = null;
            
            this.dataFileRepository = dataFileRepository;
            this.scope = $scope;
            this.jsog = JSOG;
            this.loDash = _;

            $scope.$watch(() => {
                return dataFileRepository.lastModified();
            }, () => {
                this.files = dataFileRepository.filter({});
            });

            dataFileRepository.findAll();
        }

        upload (file: any) : void {
            this.uploader.upload({
                url: '/api/files',
                file: file
            }).then((data: any) => {
                // Need to do what JS-Data would do ...

                var theData = data ? ('data' in data ? data.data : data) : data;
                var decoded = this.jsog.decode(theData);

                this.dataFileRepository.inject(decoded);
                this.loDash.pull(this.uploads, file);
            });
        }
    }

    angular.module('csrsApp').controller('DataFileListController', DataFileListController);

    angular.module('csrsApp').config(function ($stateProvider: angular.ui.IStateProvider) {
        'ngInject';

        $stateProvider.state('file-list', {
            parent: 'admin',
            url: '/files',
            data: {
                roles: ['ROLE_ADMIN'],
                pageTitle: 'files.title'
            },
            views: {
                'content@': {
                    templateUrl: 'scripts/app/admin/dataFiles/file.list.html',
                    controller: 'DataFileListController',
                    controllerAs: 'fileList'
                }
            }
        });
    });
}
