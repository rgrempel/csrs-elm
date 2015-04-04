'use strict';

angular.module('csrsApp').directive('csrsFormGroup', function () {
    return {
        require: 'csrsFormGroup',

        link: function (scope, element, attr, ctrl) {
            element.toggleClass('form-group', true);
            ctrl.element = element;
        },

        controller: function () {
            this.element = null;
            this.ngModel = null;

            this.setHasError = function (value) {
                if (this.element) {
                    this.element.toggleClass('has-error', value);
                }
            };
        }
    };
});

angular.module('csrsApp').directive('csrsFormControl', function () {
    return {
        require: ['^csrsFormGroup', 'ngModel', '^form'],
        link: function (scope, element, attr, controllers) {
            element.toggleClass('form-control', true);

            var formGroup = controllers[0];
            var ngModel = controllers[1];
            var form = controllers[2];

            formGroup.ngModel = ngModel;

            scope.$watch(
                function (scope) {
                    return ngModel.$invalid && form.$submitted;
                },
                function (newValue, oldValue) {
                    formGroup.setHasError(newValue);
                }
            );
        }
    };
});

angular.module('csrsApp').directive('csrsHelpBlock', function () {
    return {
        require: ['^csrsFormGroup', '^form'],
        link: function (scope, element, attr, controllers) {
            element.toggleClass('help-block', true);

            var formGroup = controllers[0];
            var form = controllers[1];

            // Initially hide
            element.toggleClass('hidden', true);

            scope.$watch(
                function (scope) {
                    var model = formGroup.ngModel;
                    if (model === null) {
                        return true;
                    } else {
                        return !(model.$error[attr.csrsHelpBlock] && form.$submitted);
                    }
                },
                function (newValue, oldValue) {
                    element.toggleClass('hidden', newValue);
                }
            );
        }
    };
});
