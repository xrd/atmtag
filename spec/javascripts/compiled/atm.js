(function() {
  var AtmCtrl;

  AtmCtrl = (function() {

    function AtmCtrl($scope, Bank, Store, $cookieStore) {
      var calculateCost, loadContributorPreference;
      console.log("Loaded controller");
      $scope.hideBanksMessage = function() {
        Store.save({
          'hideBanksMessage': true
        });
        return $scope.preferences.hideBanksMessage = true;
      };
      $scope.getCurrentLocation = function(cb) {
        if (navigator.geolocation) {
          return navigator.geolocation.getCurrentPosition(cb);
        }
      };
      $scope.search = function() {
        $scope.message = "Acquiring current location";
        return $scope.getCurrentLocation(function(position) {
          var request, service;
          $scope.message = "Got current location, now searching local ATMs";
          if ((typeof google !== "undefined" && google !== null) && (google.maps != null)) {
            service = new google.maps.places.PlacesService($scope.map);
            request = {};
            request.location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            request.radius = 500;
            request.types = ['atm'];
            return service.nearbySearch(request, function(results, status) {
              var bank, fee, result, vbc, _i, _j, _len, _len1, _ref;
              if (status === google.maps.places.PlacesServiceStatus.OK) {
                $scope.results = [];
                for (_i = 0, _len = results.length; _i < _len; _i++) {
                  result = results[_i];
                  _ref = $scope.banks.all;
                  for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                    bank = _ref[_j];
                    fee = calculateCost(bank.average_fee);
                    vbc = bank.validated_by_count;
                    result.fees = {
                      amount: fee,
                      vbc: vbc
                    };
                  }
                  $scope.results.push(result);
                }
                $scope.message = "Got results";
              } else {
                $scope.message = "No results found";
              }
              return $scope.$digest();
            });
          }
        });
      };
      calculateCost = function(averageFee, name) {
        var af, bank, mwf, rv, _i, _len, _ref;
        mwf = $scope.preferences.mwf;
        af = parseFloat(averageFee) || 0.0;
        rv = -1;
        if ($scope.preferences.banks) {
          _ref = $scope.preferences.banks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            bank = _ref[_i];
            if (match(bank, name)) {
              rv = 0.0;
            }
          }
        }
        if (-1 === rv) {
          rv = af + mwf;
        }
        return rv;
      };
      $scope.chooseBanks = function() {
        return console.log("Hi there");
      };
      loadContributorPreference = function() {
        return Store.get("contribute", function(result) {
          if (!($scope.preferences.contribute = result)) {
            return Store.save({
              "contribute": "yes"
            });
          }
        });
      };
      $scope.initialize = function() {
        $scope.banks = {};
        $scope.banks.all = Bank.query();
        $scope.preferences = {};
        Store.get("hideBanksMessage", function(response) {
          return $scope.preferences.hideBanksMessage = response;
        });
        loadContributorPreference();
        Store.get("banks", function(response) {
          return $scope.preferences.banks = response;
        });
        $scope.initializeMap();
        if (typeof jQuery !== "undefined" && jQuery !== null) {
          return jQuery('.cloak').removeClass('hidden');
        }
      };
      $scope.initializeMap = function() {
        var mapOptions;
        if ((typeof google !== "undefined" && google !== null) && (google.maps != null)) {
          mapOptions = {
            center: new google.maps.LatLng(-34.397, 150.644),
            zoom: 8,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          return $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
        }
      };
    }

    return AtmCtrl;

  })();

  AtmCtrl.$inject = ['$scope', 'Bank', 'Store', '$cookieStore'];

  this.AtmCtrl = AtmCtrl;

}).call(this);
