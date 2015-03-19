((ng) ->
  NgLodash = ng.module('angularLodash', [])

  ###
   create the service that loads the lodash object from the global window object
  ###
  NgLodash.factory('_', ['$window', ($window) ->
    oLodash = if typeof $window._ is "undefined" then null else $window._
    oLodash

  ])
)(angular)