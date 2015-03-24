'use strict';

angular.module('csrsApp')
    .controller('LanguageController', function ($scope, $translate, Language) {
        $scope.changeLanguage = function (languageKey) {
            if ($translate.use() !== languageKey) {
                $translate.use(languageKey);
                $translate.refresh();
                $translate.use(languageKey);
            }
        };

        Language.getAll().then(function (languages) {
            $scope.languages = languages;
        });
    });
