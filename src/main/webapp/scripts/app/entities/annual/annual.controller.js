'use strict';

angular.module('csrsApp')
    .controller('AnnualController', function ($scope, Annual, Contact, ParseLinks) {
        $scope.annuals = [];
        $scope.contacts = Contact.query();
        $scope.page = 1;
        $scope.loadAll = function() {
            Annual.query({page: $scope.page, 'per_page': 20}, function(result, headers) {
                $scope.links = ParseLinks.parse(headers('link'));
                for (var i = 0; i < result.length; i++) {
                    $scope.annuals.push(result[i]);
                }
            });
        };
        $scope.reset = function() {
            $scope.page = 1;
            $scope.annuals = [];
            $scope.loadAll();
        };
        $scope.loadPage = function(page) {
            $scope.page = page;
            $scope.loadAll();
        };
        $scope.loadAll();

        $scope.create = function () {
            Annual.update($scope.annual,
                function () {
                    $scope.reset();
                    $('#saveAnnualModal').modal('hide');
                    $scope.clear();
                });
        };

        $scope.update = function (id) {
            Annual.get({id: id}, function(result) {
                $scope.annual = result;
                $('#saveAnnualModal').modal('show');
            });
        };

        $scope.delete = function (id) {
            Annual.get({id: id}, function(result) {
                $scope.annual = result;
                $('#deleteAnnualConfirmation').modal('show');
            });
        };

        $scope.confirmDelete = function (id) {
            Annual.delete({id: id},
                function () {
                    $scope.reset();
                    $('#deleteAnnualConfirmation').modal('hide');
                    $scope.clear();
                });
        };

        $scope.clear = function () {
            $scope.annual = {year: null, membership: null, iter: null, rr: null, id: null};
        };
    });
