'use strict';

angular.module('csrsApp').directive('csrsContactFormModal', function () {
    return {
        templateUrl: 'scripts/app/tasks/processForms/contactFormModal.html',
        scope: {
            'contact': '=csrsContactFormModal',
            'submitAction': '&',
            'cancelAction': '&'
        },
        controllerAs: 'contactForm',
        bindToController: true,
        controller: 'ContactModalController',
        link: function (scope, element) {
            // put a reference to the modal element on the scope.
            // Not sure if this is the best idea, but we'll see.
            scope.modal = $(element).find('.modal');
        }
    };
});

angular.module('csrsApp').controller('ContactModalController', function ($scope) {
    this.showModal = function () {
        $scope.modal.modal('show');
    };

    this.hideModal = function () {
        $scope.modal.modal('hide');
    };

    this.save = function () {
        this.hideModal();
        this.submitAction();
    };

    this.cancel = function () {
        this.hideModal();
        this.cancelAction();
    };

    var self = this;
    this.listener = $scope.$on('startEditing', function () {
        self.showModal();
    });
});

