oAngLodash = angular.module "AppLodash", ["angularLodash"]


###
 inject the lodash service
###

oAngLodash.controller("TestCtrl", ["$scope","_", ($scope, _) ->

	oDummyItems = []
	for i in [1...20] by 1
		oDummyItems.push name: "dummy#{i}", age: Math.floor((Math.random()*100)+1)

	$scope.dummyItems = oDummyItems
	$scope.sResult = ""
	$scope.sCurrentAction = null

	$scope.pluckTest = () ->
		$scope.sResult = angular.toJson (_.pluck $scope.dummyItems, "name"), on
		$scope.sCurrentAction = "Pluck Test"
		return

	$scope.rejectTest = () ->
		oResult = _.reject $scope.dummyItems, (oVal) ->
			return oVal.age % 2 is 0
		$scope.sResult = angular.toJson oResult
		$scope.sCurrentAction = "Reject Test (only results that has odd ages )"
		return
	

	return
])