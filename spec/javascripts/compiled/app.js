(function() {
  var mod;

  mod = angular.module("atmtag", ['ngCookies', 'ngResource']);

  this.mod = mod;

  mod.factory('Bank', [
    '$resource', function($resource) {
      return $resource('/banks/:id/:action', {}, {});
    }
  ]);

  mod.factory('Preferences', [
    function(store) {
      console.log("Creating store service (lawnchair)");
      store = {};
      Lawnchair({
        name: 'atmtag'
      }, function(lawnchair) {
        store = {};
        store.get = function(key, cb) {
          console.log("Getting preference for: " + key);
          return lawnchair.get("preferences." + key, function(response) {
            var value;
            if ((response != null) && response[key]) {
              value = response[key].value;
            }
            console.log("Got preferences." + key + " => " + value);
            return cb(value);
          });
        };
        return store.set = function(key, value) {
          console.log("Setting preference for: " + key + " to " + value);
          return lawnchair.get("preferences." + key, function(response) {
            if (!response) {
              response = {};
            }
            response[key] = value;
            return lawnchair.save(response);
          });
        };
      });
      return store;
    }
  ]);

}).call(this);
