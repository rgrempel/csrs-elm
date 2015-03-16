'use strict';

angular.module('csrsApp').controller('ProcessFormsController', function ($scope, $stateParams, Contact, $location) {
    $scope.search = $stateParams.search;

    $scope.performSearch = function () {
        if ($location.search('search') != $scope.search) {
            $location.search('search', $scope.search);
            $location.replace();
        }

        if ($scope.search) {
            Contact.query({
                fullNameSearch: $scope.search
            }, function (result, headers) {
                $scope.results = result;
            });
        } else {
            $scope.results = [];
        }
    };

    // Initial search if we had params
    $scope.performSearch();

    $scope.create = function () {
        Contact.update($scope.contact,
            function () {
                $scope.loadAll();
                $('#saveContactModal').modal('hide');
                $scope.clear();
            });
    };

    $scope.update = function (id) {
        Contact.get({id: id}, function(result) {
            $scope.contact = result;
            $('#saveContactModal').modal('show');
        });
    };

    $scope.delete = function (id) {
        Contact.get({id: id}, function(result) {
            $scope.contact = result;
            $('#deleteContactConfirmation').modal('show');
        });
    };

    $scope.confirmDelete = function (id) {
        Contact.delete({id: id},
            function () {
                $scope.loadAll();
                $('#deleteContactConfirmation').modal('hide');
                $scope.clear();
            });
    };

    $scope.clear = function () {
        $scope.contact = {code: null, firstName: null, lastName: null, salutation: null, street: null, city: null, region: null, country: null, postalCode: null, email: null, id: null};
    };
});
