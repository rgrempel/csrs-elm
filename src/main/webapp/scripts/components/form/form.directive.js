/* globals $ */
'use strict';

angular.module('csrsApp')
    .directive('showValidation', function() {
        return {
            restrict: 'A',
            require: 'form',
            link: function (scope, element, attr, formCtrl) {
                element.find('.form-group').each(function() {
                    var $formGroup = $(this);
                    var $inputs = $formGroup.find('input[ng-model],textarea[ng-model],select[ng-model]');

                    if ($inputs.length > 0) {
                        $inputs.each(function() {
                            var $input = $(this);
                            scope.$watch(function() {
                                return $input.hasClass('ng-invalid') && ($input.hasClass('ng-touched') || formCtrl.$submitted);
                            }, function(isInvalid) {
                                $formGroup.toggleClass('has-error', isInvalid);
                            });
                        });
                    }
                });
            }
        };
    });
