(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        define([ 'module', 'angular' ], function (module, angular) {
            module.exports = factory(angular);
        });
    } else if (typeof module === 'object') {
        module.exports = factory(require('angular'));
    } else {
        if (!root.mp) {
            root.mp = {};
        }

        root.mp.autoFocus = factory(root.angular);
    }
}(this, function (angular) {
    'use strict';

    return angular.module('mp.autoFocus', [])
        .directive('autoFocus', [ '$timeout', function ($timeout) {
            return {
                restrict: 'A',

                link: function ($scope, $element, $attributes) {
                    if ($scope.$eval($attributes.autoFocus) !== false) {
                        var element = $element[0];

                        $timeout(function() {
                            $scope.$emit('focus', element);
                            element.focus();
                        });
                    }
                }
            };
        } ]);
}));
