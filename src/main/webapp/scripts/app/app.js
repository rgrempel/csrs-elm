'use strict';

angular.module('csrsApp', [
    'LocalStorageModule',
    'tmh.dynamicLocale',
    'ngResource', 
    'ui.router', 
    'ngCookies', 
    'pascalprecht.translate', 
    'ngCacheBuster', 
    'infinite-scroll', 
    'mp.autoFocus', 
    'angularLodash',
    'ngAnimate'
])
    .run(function ($rootScope, $location, $window, $http, $state, $translate, Auth, Principal, Language, ENV, VERSION, _) {
        $rootScope._ = _;
        $rootScope.ENV = ENV;
        $rootScope.VERSION = VERSION;
        $rootScope.$on('$stateChangeStart', function (event, toState, toStateParams) {
            $rootScope.toState = toState;
            $rootScope.toStateParams = toStateParams;

            if (Principal.isIdentityResolved()) {
                Auth.authorize();
            }

            // Update the language
            Language.getCurrent().then(function (language) {
                if ($translate.use() !== language) {
                    $translate.use(language);
                    $translate.refresh();
                    $translate.use(language);
                }
            });
        });

        $rootScope.$on('$stateChangeSuccess',  function(event, toState, toParams, fromState, fromParams) {
            var titleKey = 'global.title';

            $rootScope.previousStateName = fromState.name;
            $rootScope.previousStateParams = fromParams;

            // Set the page title key to the one configured in state or use default one
            if (toState.data.pageTitle) {
                titleKey = toState.data.pageTitle;
            }
            $translate(titleKey).then(function (title) {
                // Change window title with translated one
                $window.document.title = title;
            });
        });

        $rootScope.back = function() {
            // If previous state is 'activate' or do not exist go to 'home'
            if ($rootScope.previousStateName === 'activate' || $state.get($rootScope.previousStateName) === null) {
                $state.go('home');
            } else {
                $state.go($rootScope.previousStateName, $rootScope.previousStateParams);
            }
        };
    })
    
    .config(function ($stateProvider, $urlRouterProvider, $httpProvider, $locationProvider, $translateProvider, tmhDynamicLocaleProvider, httpRequestInterceptorCacheBusterProvider) {
        $locationProvider.hashPrefix('!');

        //enable CSRF
        $httpProvider.defaults.xsrfCookieName = 'CSRF-TOKEN';
        $httpProvider.defaults.xsrfHeaderName = 'X-CSRF-TOKEN';

        //Cache everything except rest api requests
        httpRequestInterceptorCacheBusterProvider.setMatchlist([/.*api.*/, /.*protected.*/], true);

        // Initialize angular-translate
        $translateProvider.useStaticFilesLoader({
            prefix: 'i18n/',
            suffix: '.json'
        });

        var language;

        if (window) {
            var navigator = window.navigator;
            language = (navigator.languages && navigator.languages[0]) ||
                            navigator.language ||
                            navigator.browserLanguage ||
                            navigator.systemLanguage ||
                            navigator.userLanguage;
        }

        if (language && (language.substr(0, 2).toLowerCase() === 'fr')) {
            $translateProvider.preferredLanguage('fr');
        } else {
            $translateProvider.preferredLanguage('en');
        }

        $translateProvider.useCookieStorage();
        
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
                authorize: ['Auth',
                    function (Auth) {
                        return Auth.authorize();
                    }
                ]
            }
        });
        
        tmhDynamicLocaleProvider.localeLocationPattern('bower_components/angular-i18n/angular-locale_{{locale}}.js');
        tmhDynamicLocaleProvider.useCookieStorage('NG_TRANSLATE_LANG_KEY');
    });
