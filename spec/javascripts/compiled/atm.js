(function() {
  var AtmCtrl;

  AtmCtrl = (function() {

    function AtmCtrl($scope, Bank, Preferences, $cookieStore, $location, $anchorScroll) {
      var calculateCost, loadContributorPreference;
      $scope.maps = {};
      $scope.attempted = false;
      $scope.radius = 500;
      $scope.metric = false;
      $scope.$watch('preferences.contribute', function(newVal, oldVal) {
        if (newVal !== oldVal) {
          return Preferences.set("contribute", newVal);
        }
      });
      $scope.changeRadius = function(count) {
        var radius;
        if (!count) {
          if (radius = window.prompt("Enter the search radius (in " + ($scope.metric ? 'km' : 'mi') + ")")) {
            $scope.radius = radius * 1000;
            if (!$scope.metric) {
              $scope.radius *= 0.6;
            }
            return $scope.search();
          }
        } else {
          $scope.radius = count;
          return $scope.search();
        }
      };
      $scope.convert = function(distance) {
        if ($scope.metric) {
          return distance;
        } else {
          return distance * 0.6;
        }
      };
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
        $scope.results = void 0;
        $scope.message = "Acquiring current location";
        return $scope.getCurrentLocation(function(position) {
          var request, service;
          $scope.message = "Got current location, now searching local ATMs";
          if ((typeof google !== "undefined" && google !== null) && (google.maps != null)) {
            service = new google.maps.places.PlacesService($scope.map);
            request = {};
            $scope.current = {
              lat: position.coords.latitude,
              lng: position.coords.longitude
            };
            request.location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
            request.radius = $scope.radius;
            request.types = ['atm'];
            return service.nearbySearch(request, function(results, status) {
              $scope.attempted = true;
              if (status === google.maps.places.PlacesServiceStatus.OK) {
                $scope.results = results;
                $scope.calculateFeesForResults();
                $scope.calculateDistances(position.coords);
                $scope.message = "";
              } else {
                $scope.message = "No results found";
              }
              return $scope.$digest();
            });
          }
        });
      };
      $scope.calculateDistances = function(current) {
        var R, a, c, d, dLat, dLon, lat1, lat2, lon1, lon2, result, toRad, _i, _len, _ref, _results;
        toRad = function(Value) {
          return Value * Math.PI / 180;
        };
        _ref = $scope.results;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          result = _ref[_i];
          lat1 = current.latitude;
          lon1 = current.longitude;
          lat2 = result.geometry.location.lat();
          lon2 = result.geometry.location.lng();
          console.log("Lat/lng: " + lat1 + "/" + lon1 + " vs. " + lat2 + "/" + lon2);
          R = 6371;
          dLat = toRad(lat2 - lat1);
          dLon = toRad(lon2 - lon1);
          lat1 = toRad(lat1);
          lat2 = toRad(lat2);
          a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
          c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
          d = R * c;
          console.log("Distance: " + d);
          _results.push(result.distance = d);
        }
        return _results;
      };
      $scope.iob = function(expanded) {
        if (expanded) {
          return "expanded";
        } else {
          return "tight";
        }
      };
      $scope.help = function(result) {
        var fee, lat, lng, name;
        if (fee = window.prompt("Do you know the actual fee at this ATM? If so, please contribute the amount to improve estimations")) {
          lat = result.geometry.location.lat;
          lng = result.geometry.location.lng;
          name = result.name;
          return Bank.add_estimation({}, {
            estimation: {
              fee: fee,
              lat: lat,
              lng: lng,
              name: name,
              uid: result.id
            }
          }, function(response) {
            if ("ok" === response.status) {
              return result.$scope.calculateFeesForResults();
            } else {

            }
          });
        }
      };
      $scope.setBankFee = function(bank) {
        var fee;
        if (fee = window.prompt("What fee do you pay at this bank?")) {
          bank.myFee = fee;
          console.log("Fee: " + bank.myFee);
          return $scope.calculateFeesForResults();
        }
      };
      $scope.calculateFeesForResults = function() {
        var bank, fee, gBank, vbc, _i, _len, _ref, _results;
        if ($scope.banks.all && $scope.results) {
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
        }
      };
      calculateCost = function(gBank, bank) {
        var af, mwf, myBank, rv, _i, _len, _ref;
        mwf = $scope.preferences.mwf || 2.5;
        console.log("Checking costs for " + bank.name + ": " + bank.myFee + " vs " + bank.averageFee);
        af = bank.myFee || parseFloat(bank.averageFee) || 2.5;
        rv = -1;
        if ($scope.preferences.banks) {
          _ref = $scope.preferences.banks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            myBank = _ref[_i];
            if ($scope.match(myBank.name, gBank.name)) {
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
        $scope.banks.chooser = true;
        return $('.modal').css({
          left: '300px',
          top: '250px',
          width: '280px'
        });
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
        $scope.preferences = {};
        Preferences.get("hideBanksMessage", function(response) {
          return $scope.preferences.hideBanksMessage = response;
        });
        loadContributorPreference();
        Preferences.get("banks", function(response) {
          return $scope.preferences.banks = response;
        });
        return Preferences.all(function(response) {
          return $scope.allPrefs = response;
        });
      };
      $scope.loadBanks = function() {
        $scope.banks = {};
        return Bank.query(function(response) {
          return $scope.banks.all = response;
        });
      };
      $scope.addBank = function(bank) {
        var _base;
        (_base = $scope.preferences).banks || (_base.banks = []);
        $scope.preferences.banks.push(bank);
        Preferences.set("banks", $scope.preferences.banks);
        $scope.bank = void 0;
        return $scope.calculateFeesForResults();
      };
      $scope.verifyUser = function() {};
      $scope.initialize = function() {
        $scope.verifyUser();
        $scope.loadBanks();
        $scope.loadPreferences();
        $scope.initializeMap();
        if (typeof jQuery !== "undefined" && jQuery !== null) {
          return jQuery('.cloak').removeClass('hidden');
        }
      };
      $scope.removeBank = function(bank) {
        var toRemove;
        if (confirm("Remove bank " + bank.name + " from your ATM card list?")) {
          if (-1 !== (toRemove = $scope.preferences.banks.indexOf(bank))) {
            $scope.preferences.banks.splice(toRemove, 1);
            Preferences.set("banks", $scope.preferences.banks);
            return $scope.calculateFeesForResults();
          }
        }
      };
      $scope.focusOnMap = function(item) {
        var atm, center, cur, current, mapOptions;
        if ((typeof google !== "undefined" && google !== null) && (google.maps != null)) {
          center = new google.maps.LatLng(item.geometry.location.lat(), item.geometry.location.lng());
          current = new google.maps.LatLng($scope.current.lat, $scope.current.lng);
          mapOptions = {
            center: center,
            zoom: 15,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
          cur = new google.maps.Marker({
            position: current,
            map: $scope.map,
            icon: '/assets/yellow_MarkerA.png'
          });
          atm = new google.maps.Marker({
            position: center,
            map: $scope.map,
            icon: '/assets/green_MarkerZ.png'
          });
          $scope.maps.atm = item;
          return $scope.maps.display = true;
        }
      };
      $scope.initializeMap = function() {
        var center, mapOptions;
        if ((typeof google !== "undefined" && google !== null) && (google.maps != null)) {
          center = new google.maps.LatLng(50, 50);
          mapOptions = {
            center: center,
            zoom: 15,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          return $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
        }
      };
    }

    return AtmCtrl;

  })();

  AtmCtrl.$inject = ['$scope', 'Bank', 'Preferences', '$cookieStore', '$location', '$anchorScroll'];

  this.AtmCtrl = AtmCtrl;

}).call(this);
