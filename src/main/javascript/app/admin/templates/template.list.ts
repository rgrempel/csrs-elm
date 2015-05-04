/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    interface TemplateListScope extends angular.IScope {
        editForm: angular.IFormController;
    }
    
    class TemplateListController {
        templates: Array<Template>;
        serverError: string;
        scope: TemplateListScope;
        templateRepository: JSData.DSResourceDefinition<Template>;
        template: Template;

        constructor (templateRepository: JSData.DSResourceDefinition<Template>, $scope: TemplateListScope) {
            'ngInject';

            this.serverError = null;
            this.template = {
                text: ""
            };
            this.templateRepository = templateRepository;
            this.scope = $scope;

            $scope.$watch(() => {
                return templateRepository.lastModified();
            }, () => {
                this.templates = templateRepository.filter({});
            });

            templateRepository.findAll();
        }

        create () {
            if (!this.scope.editForm.$valid) {return;}

            this.templateRepository.create(this.template).then(() => {
                this.template = {
                    text: ""
                };
                this.scope.editForm.$setPristine();
                this.serverError = null;
            }, (error: any) => {
                this.serverError = angular.toJson(error);
            });
        }
    }

    angular.module('csrsApp').controller('TemplateListController', TemplateListController);

    angular.module('csrsApp').config(function ($stateProvider: angular.ui.IStateProvider) {
        'ngInject';

        $stateProvider.state('template-list', {
            parent: 'admin',
            url: '/templates',
            data: {
                roles: ['ROLE_ADMIN'],
                pageTitle: 'templates.title'
            },
            views: {
                'content@': {
                    templateUrl: 'scripts/app/admin/templates/template.list.html',
                    controller: 'TemplateListController',
                    controllerAs: 'templateListController'
                }
            }
        });
    });
}
