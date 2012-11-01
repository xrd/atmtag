(function() {
  var AtmCtrl;

  AtmCtrl = (function() {

    function AtmCtrl($scope, Bank, Preferences, $cookieStore) {
      var calculateCost, loadContributorPreference;
      console.log("Loaded controller");
      $scope.hideBanksMessage = function() {
        Preferences.set('hideBanksMessage', true);
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
              if (status === google.maps.places.PlacesServiceStatus.OK) {
                $scope.results = results;
                $scope.calculateFeesForResults();
                $scope.message = "Got results";
              } else {
                $scope.message = "No results found";
              }
              return $scope.$digest();
            });
          }
        });
      };
      $scope.calculateFeesForResults = function() {
        var bank, fee, gBank, vbc, _i, _len, _ref, _results;
        _ref = $scope.banks.all;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          bank = _ref[_i];
          _results.push((function() {
            var _j, _len1, _ref1, _results1;
            _ref1 = $scope.results;
            _results1 = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              gBank = _ref1[_j];
              fee = calculateCost(gBank, bank);
              vbc = bank.validated_by_count;
              _results1.push(gBank.fees = {
                amount: fee,
                vbc: vbc
              });
            }
            return _results1;
          })());
        }
        return _results;
      };
      calculateCost = function(gBank, bank) {
        var af, mwf, myBank, rv, _i, _len, _ref;
        mwf = $scope.preferences.mwf || 2.5;
        af = parseFloat(bank.averageFee) || 2.5;
        rv = -1;
        if ($scope.preferences.banks) {
          _ref = $scope.preferences.banks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            myBank = _ref[_i];
            if ($scope.match(myBank.name, gBank.name)) {
              console.log("Got a match of our bank " + myBank.name + " / " + gBank.name + "!");
              rv = 0.0;
            }
          }
        }
        if (-1 === rv) {
          rv = af + mwf;
        }
        return rv;
      };
      $scope.match = function(bank_mixed, name_mixed) {
        var bank, name, nw_bank, nw_name, rv;
        if (!(bank_mixed && name_mixed)) {
          return false;
        }
        name = name_mixed.toLowerCase();
        bank = bank_mixed.toLowerCase();
        rv = false;
        rv = bank === name;
        if (!rv) {
          rv = (-1 !== name.indexOf(bank)) || (-1 !== bank.indexOf(name));
        }
        if (!rv) {
          nw_bank = bank.replace(/\W+/, '');
          nw_name = name.replace(/\W+/, '');
          rv = nw_name === nw_bank;
          if (!rv) {
            rv = (-1 !== nw_name.indexOf(nw_bank)) || (-1 !== nw_bank.indexOf(nw_name));
          }
        }
        return rv;
      };
      $scope.chooseBanks = function() {
        return console.log("Hi there");
      };
      loadContributorPreference = function() {
        return Preferences.get("contribute", function(result) {
          console.log("Retrieving contribute " + result);
          $scope.preferences.contribute = result;
          if (!result) {
            Preferences.set("contribute", "yes");
            return $scope.preferences.contribute = "yes";
          } else {
            return console.log("Defined: " + $scope.preferences.contribute);
          }
        });
      };
      $scope.loadPreferences = function() {
        console.log("Loading preferences");
        $scope.preferences = {};
        console.log("Getting banks message");
        Preferences.get("hideBanksMessage", function(response) {
          console.log("Retrieving preferences for banks: " + response);
          return $scope.preferences.hideBanksMessage = response;
        });
        console.log("Getting contributor message");
        loadContributorPreference();
        return Preferences.get("banks", function(response) {
          console.log("Retrieving preferences for all banks: " + response);
          return $scope.preferences.banks = response;
        });
      };
      $scope.loadBanks = function() {
        $scope.banks = {};
        return Bank.query(function(response) {
          return $scope.banks.all = response;
        });
      };
      $scope.addBank = function() {
        var _base;
        (_base = $scope.preferences).banks || (_base.banks = []);
        $scope.preferences.banks.push($scope.bank);
        $scope.bank = void 0;
        return $scope.calculateFeesForResults();
      };
      $scope.initialize = function() {
        $scope.loadBanks();
        $scope.loadPreferences();
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

  AtmCtrl.$inject = ['$scope', 'Bank', 'Preferences', '$cookieStore'];

  this.AtmCtrl = AtmCtrl;

}).call(this);
