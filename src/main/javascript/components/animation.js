'use strict';

angular.module('csrsApp').directive('csrsAnimateOnChange', function ($animate) {
    return {
        scope: {
            csrsAnimateOnChange: '='
        },

        link: function (scope, element /*, attr*/) {
            scope.$watch('csrsAnimateOnChange', function (oldValue, newValue) {
                if (oldValue !== newValue) {
                    $animate.removeClass(element, 'value-changed').finally(function () {
                        scope.$apply(function () {
                            $animate.addClass(element, 'value-changed');
                        });
                    });
                }
            });
        }
    };
});
