;(function () {
    'use strict';

    angular.module('csrsApp').run(StateTracker);

    function StateTracker ($rootScope, $state, _, Language, $translate, ENV, VERSION, Principal, Auth, $window, amMoment) {
        'ngInject';

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

                    amMoment.changeLocale(language + "-ca");
                }
            });
        });

        $rootScope.$on('$stateChangeSuccess',  function (event, toState, toParams, fromState, fromParams) {
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

        $rootScope.back = function () {
            // If previous state is 'activate' or do not exist go to 'home'
            if ($rootScope.previousStateName === 'activate' || $state.get($rootScope.previousStateName) === null) {
                $state.go('home');
            } else {
                $state.go($rootScope.previousStateName, $rootScope.previousStateParams);
            }
        };
    }
})();
