;(function () {
    'use strict';

    angular.module('csrsApp').config(TranslationConfigurer);

    function TranslationConfigurer ($translateProvider, $windowProvider) {
        'ngInject';

        // Initialize angular-translate
        $translateProvider.useStaticFilesLoader({
            prefix: 'i18n/',
            suffix: '.json'
        });

        var language;

        var $window = $windowProvider.$get();

        if ($window) {
            var navigator = $window.navigator;
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
    }
})();
