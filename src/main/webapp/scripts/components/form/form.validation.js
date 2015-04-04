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
            var validateAfterSubmission = (attr.csrsValidate !== 'always');
            var pending = (attr.csrsValidate === 'pending');

            // Initially hide
            element.toggleClass('hidden', true);

            scope.$watch(
                function (scope) {
                    var model = formGroup.ngModel;
                    if (model === null) {
                        return true;
                    } else {
                        if (pending) {
                            return !(model.$pending && model.$pending[attr.csrsHelpBlock]);
                        } else if (validateAfterSubmission && !form.$submitted) {
                            return true;
                        } else {
                            return !(model.$error[attr.csrsHelpBlock]);
                        }
                    }
                },
                function (newValue, oldValue) {
                    element.toggleClass('hidden', newValue);
                }
            );
        }
    };
});

angular.module('csrsApp').directive('csrsValidateMatches', function () {
    return {
        require: 'ngModel',

        scope: {
            csrsValidateMatches: '='
        },

        link: function (scope, element, attr, ngModel) {
            ngModel.$validators.csrsValidateMatches = function (modelValue, viewValue) {
                return modelValue === scope.csrsValidateMatches;
            };
            
            scope.$watch("csrsValidateMatches", function() {
                ngModel.$validate();
            });
        }
    };
});
