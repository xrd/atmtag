(function() {
  var mod;

  mod = angular.module("atmtag", ['ngCookies', 'ngResource']);

  this.mod = mod;

  mod.factory('Bank', [
    '$resource', function($resource) {
      return $resource('/banks/:id/:action', {}, {});
    }
  ]);

  mod.factory('Store', [
    function(store) {
      return new Lawnchair({
        name: 'atmtag'
      }, function(store) {
        return store;
      });
    }
  ]);

}).call(this);
