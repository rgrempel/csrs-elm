var oAngLodash;

oAngLodash = angular.module("AppLodash", ["angularLodash"]);

/*
 inject the lodash service
*/


oAngLodash.controller("TestCtrl", [
  "$scope", "_", function($scope, _) {
    var i, oDummyItems, _i;
    oDummyItems = [];
    for (i = _i = 1; _i < 20; i = _i += 1) {
      oDummyItems.push({
        name: "dummy" + i,
        age: Math.floor((Math.random() * 100) + 1)
      });
    }
    $scope.dummyItems = oDummyItems;
    $scope.sResult = "";
    $scope.sCurrentAction = null;
    $scope.pluckTest = function() {
      $scope.sResult = angular.toJson(_.pluck($scope.dummyItems, "name"), true);
      $scope.sCurrentAction = "Pluck Test";
    };
    $scope.rejectTest = function() {
      var oResult;
      oResult = _.reject($scope.dummyItems, function(oVal) {
        return oVal.age % 2 === 0;
      });
      $scope.sResult = angular.toJson(oResult);
      $scope.sCurrentAction = "Reject Test (only results that has odd ages )";
    };
  }
]);
