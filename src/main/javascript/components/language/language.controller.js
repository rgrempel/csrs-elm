'use strict';

angular.module('csrsApp')
    .controller('LanguageController', function ($scope, $translate, Language, Auth, Principal) {
        $scope.changeLanguage = function (languageKey) {
            if ($translate.use() !== languageKey) {
                $translate.use(languageKey);
                $translate.refresh();
                $translate.use(languageKey);

                // And let the server know about the preference ...
                Principal.identity().then(function (account) {
                    account.langKey = languageKey;
                    Auth.updateAccount(account);
                });
            }
        };

        Language.getAll().then(function (languages) {
            $scope.languages = languages;
        });
    });