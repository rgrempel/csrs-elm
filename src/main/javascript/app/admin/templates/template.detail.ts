/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    interface TemplateDetailScope extends angular.IScope {
        editForm: angular.IFormController;
    }
    
    class TemplateDetailController {
        serverError: string;
        templateRepository: JSData.DSResourceDefinition<Template>;
        template: Template;
        scope: TemplateDetailScope;
        state: angular.ui.IStateService;
        templateId: number;
        codemirrorOptions: any;

        constructor (templateRepository: JSData.DSResourceDefinition<Template>, $scope: TemplateDetailScope, $state: angular.ui.IStateService) {
            'ngInject';

            this.serverError = null;
            this.templateRepository = templateRepository;
            this.scope = $scope;
            this.templateId = $state.params['id'];
            this.state = $state;

            this.codemirrorOptions = {
                mode: 'xml',
                indentUnit: 4
            };

            $scope.$watch(() => {
                return templateRepository.lastModified(this.templateId);
            }, () => {
                this.template = templateRepository.get(this.templateId);
            });

            templateRepository.find(this.templateId).then((template: Template) => {
                if (template.text == null) {
                    // Must have got it from the cache, so bypass the cache ...
                    templateRepository.find(this.templateId, {
                        bypassCache: true
                    });
                }
            });
        }

        update () {
            if (!this.scope.editForm.$valid) {return;}

            this.templateRepository.save(this.templateId).then(() => {
                this.state.go('template-list');
            }, (error: any) => {
                this.serverError = angular.toJson(error);
            });
        }
    }

    angular.module('csrsApp').controller('TemplateDetailController', TemplateDetailController);

    angular.module('csrsApp').config(function ($stateProvider: angular.ui.IStateProvider) {
        'ngInject';

        $stateProvider.state('template-detail', {
            parent: 'admin',
            url: '/templates/{id}',
            data: {
                roles: ['ROLE_ADMIN'],
                pageTitle: 'templates.title'
            },
            views: {
                'content@': {
                    templateUrl: 'scripts/app/admin/templates/template.detail.html',
                    controller: 'TemplateDetailController',
                    controllerAs: 'templateDetail'
                }
            }
        });
    });
}
