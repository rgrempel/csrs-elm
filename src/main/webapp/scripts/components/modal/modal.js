'use strict';

angular.module('csrsApp').directive('csrsModal', function () {
    return {
        templateUrl: 'scripts/components/modal/modal.html',
        transclude: true,
        link: function (scope, element, attr, ctrl, transclude) {
            transclude (scope, function (clone, transcludedScope) {
                var content = $(element).find('.modal-content');
                content.append(clone);
            });

            if (attr.csrsModal == "sm" || attr.csrsModal == "lg") {
                var modalDialog = $(element).find('.modal-dialog');
                modalDialog.toggleClass('modal-' + attr.csrsModal, true);
            }

            var modal = $(element).find('.modal');
            modal.modal({
                show: true,
                backdrop: 'static',
                keyboard: false
            });
            
            var deregister = scope.$on('hide.bs.modal', function () {
                deregister();
                modal.modal('hide');
            });

            modal.one('hidden.bs.modal', function () {
                scope.$broadcast('hidden.bs.modal');
            });
        },
        controller: 'ModalController',
        controllerAs: 'modalController'
    };
});

angular.module('csrsApp').controller('ModalController', function ($scope, $state) {
    this.go = function (a, b, c) {
        var deregister = $scope.$on('hidden.bs.modal', function () {
            deregister();
            $state.go(a, b, c);
        });

        $scope.$emit('hide.bs.modal');
    };
});
