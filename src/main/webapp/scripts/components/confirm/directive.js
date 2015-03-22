'use strict';

angular.module('csrsApp').directive('csrsConfirm', function () {
    return {
        scope: true,
        link: function (scope, element) {
            scope.doConfirm = function () {
                $(element).find('.modal').modal('show');
            };
        }
    };
});

angular.module('csrsApp').directive('csrsModal', function () {
    return {
        transclude: true,
        templateUrl: 'scripts/components/confirm/template.html',
        scope: {
            actionTitle: '@',
            modalTitle: '@',
            csrsModal: '&'
        },
        link: function (scope, element) {
            scope.doAction = function () {
                $(element).find('.modal').modal('hide');
                scope.csrsModal();
            };
        }
    };
});
