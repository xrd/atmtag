(function() {
  var mod;

  mod = angular.module("atmtag", ['ngCookies', 'ngResource', 'ui']);

  this.mod = mod;

  mod.factory('Bank', [
    '$resource', function($resource) {
      return $resource('/banks/:id/:action', {}, {
        fee: {
          method: 'POST',
          params: {
            action: "fee"
          },
          isArray: false
        }
      });
    }
  ]);

  mod.factory('User', [
    '$resource', function($resource) {
      return $resource('/users/:id/:action', {}, {
        create_from_token: {
          method: 'POST',
          params: {
            action: "create_from_token"
          },
          isArray: false
        }
      });
    }
  ]);

  mod.factory('Preferences', [
    function(store) {
      console.log("Creating store service (lawnchair)");
      store = {};
      Lawnchair(function(lawnchair) {
        store = {};
        store.get = function(key, cb) {
          console.log("Getting preference for: " + key);
          return lawnchair.get(key, function(response) {
            var value;
            if (response != null) {
              value = response.value;
            }
            console.log("Got " + key + " => " + value);
            return cb(value);
          });
        };
        store.set = function(key, value) {
          console.log("Setting preference for: " + key + " to " + value);
          return lawnchair.save({
            key: key,
            value: value
          });
        };
        return store.all = function(cb) {
          return lawnchair.all(cb);
        };
      });
      return store;
    }
  ]);

}).call(this);
