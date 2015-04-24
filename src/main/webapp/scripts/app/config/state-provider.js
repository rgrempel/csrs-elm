;(function () {
    'use strict';

    angular.module('csrsApp').config(StateProviderConfigurer);
        
    function StateProviderConfigurer ($stateProvider, $urlRouterProvider, $locationProvider) {
        'ngInject';
        
        $locationProvider.hashPrefix('!');
        
        $urlRouterProvider.otherwise('/');

        $stateProvider.state('site', {
            'abstract': true,

            views: {
                'navbar@': {
                    templateUrl: 'scripts/components/navbar/navbar.html',
                    controller: 'NavbarController'
                },

                'modal@': {
                    template: '<div></div>'
                }
            },

            resolve: {
                authorize: authorize
            }
        });
    }

    function authorize (Auth) {
        'ngInject';

        return Auth.authorize();
    }
})();
