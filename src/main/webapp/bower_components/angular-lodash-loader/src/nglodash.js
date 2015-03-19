(function(ng) {
  var NgLodash;
  NgLodash = ng.module('angularLodash', []);
  /*
   create the service that loads the lodash object from the global window object
  */

  return NgLodash.factory('_', [
    '$window', function($window) {
      var oLodash;
      oLodash = typeof $window._ === "undefined" ? null : $window._;
      return oLodash;
    }
  ]);
})(angular);
