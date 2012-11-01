(function() {

  describe("AtmCtrl", function() {
    var ctrl, httpBackend, lc, scope;
    ctrl = void 0;
    scope = void 0;
    httpBackend = void 0;
    lc = void 0;
    beforeEach(module('atmtag'));
    beforeEach(function() {
      console.log("Creating new lawnchair");
      return Lawnchair({
        name: "atmtag"
      }, function(store) {
        store.keys(function(keys) {
          var k, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = keys.length; _i < _len; _i++) {
            k = keys[_i];
            _results.push(console.log("Keys: " + k));
          }
          return _results;
        });
        console.log("Created new lawnchair");
        store.nuke();
        lc = store;
        return console.log("Nuked lawnchair");
      });
    });
    beforeEach(inject(function($controller, $rootScope, $httpBackend) {
      httpBackend = $httpBackend;
      $httpBackend.whenGET(/banks/).respond(banks);
      scope = $rootScope.$new();
      return ctrl = $controller(AtmCtrl, {
        $scope: scope
      });
    }));
    afterEach(function() {
      httpBackend.verifyNoOutstandingExpectation();
      return httpBackend.verifyNoOutstandingRequest();
    });
    xdescribe("#banks", function() {
      it("should load banks", function() {
        expect(scope.banks).toEqual(void 0);
        scope.initialize();
        httpBackend.flush();
        return expect(scope.banks.all[0].name).toEqual("Chris Bank");
      });
      return void 0;
    });
    xdescribe("#costs", function() {
      return it("should layer cost estimations based on selected banks", function() {
        scope.initialize();
        httpBackend.flush();
        expect(scope.banks.all[0].cost).toEqual(void 0);
        return console.log("Hey, layering costs");
      });
    });
    describe("#match", function() {
      it("should match two banks with the same name", function() {
        return expect(scope.match("Chase", "Chase")).toBeTruthy();
      });
      it("should not match two banks with different names", function() {
        return expect(scope.match("Wells Fargo", "Chase")).toBeFalsy();
      });
      it("should match with different whitespace or punctuation", function() {
        return expect(scope.match("Chase   ", "Chase")).toBeTruthy();
      });
      it("should match partial names", function() {
        expect(scope.match("Chase Bank", "Chase")).toBeTruthy();
        expect(scope.match("Chase ", "Chase Bank")).toBeTruthy();
        return expect(scope.match("Chase       ", "Chase Bank           ")).toBeTruthy();
      });
      it("should not match partial names with stuff in the middle", function() {
        return expect(scope.match("Chase XXX Bank", "Chase Bank")).toBeFalsy();
      });
      return it("should match regardless of case", function() {
        return expect(scope.match("CHaSe", "ChASE BAnK")).toBeTruthy();
      });
    });
    xdescribe("#preferences", function() {
      xit("should store and nuke settings", function() {
        var all;
        console.log("Checking interface for lanwchair");
        all = [];
        lc.keys(function(keys) {
          var k, _i, _len;
          for (_i = 0, _len = keys.length; _i < _len; _i++) {
            k = keys[_i];
            console.log("Key: " + k);
            all.push(k);
          }
          return expect(all.length).toEqual(0);
        });
        lc.get("foo", function(response) {});
        expect(response).toEqual(void 0);
        console.log("Validated empty foo");
        lc.save({
          key: "foo",
          value: "bar"
        });
        console.log("Saved foo and bar");
        return lc.get("foo", function(response) {
          console.log("Retreived foo now bar");
          expect(response.value).toEqual("bar");
          return console.log("All sanity checks for store pass");
        });
      });
      it("should start with preferences unset after initialization", function() {
        expect(scope.preferences).toEqual(void 0);
        scope.initialize();
        httpBackend.flush();
        return expect(scope.preferences.hideBanksMessage).toBeTruthy();
      });
      it("should start with preferences", function() {
        spyOn(scope, 'loadPreferences');
        return expect(scope.preferences).toEqual(void 0);
      });
      it("should start with preferences unset after initialization", function() {
        console.log("Checking preferences prior to init");
        spyOn(scope, 'loadPreferences');
        expect(scope.preferences).toEqual(void 0);
        console.log("Checking preferences after to init");
        scope.initialize();
        httpBackend.flush();
        return expect(scope.loadPreferences).toHaveBeenCalled();
      });
      it("should start with preferences retrieved properly after initialization", function() {
        lc.save({
          key: "preferences.contribute",
          value: "no"
        });
        lc.get("preferences.contribute", function(value) {
          return expect(value.value).toEqual("no");
        });
        expect(scope.preferences).toEqual(void 0);
        scope.initialize();
        httpBackend.flush();
        return expect(scope.preferences.contribute).toEqual("no");
      });
      it("should start with contributor preferences set to 'yes' the first time after initialization", function() {
        expect(scope.preferences).toEqual(void 0);
        scope.initialize();
        httpBackend.flush();
        return expect(scope.preferences.contribute).toEqual("yes");
      });
      afterEach(function() {
        var i, _i, _len, _ref, _results;
        _ref = [lc];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          console.log("Reviewing keys for " + i);
          _results.push(i.keys(function(keys) {
            var k, _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = keys.length; _j < _len1; _j++) {
              k = keys[_j];
              _results1.push(lc.get(k, function(value) {
                return console.log("*** Used key: " + k + " / " + value.value);
              }));
            }
            return _results1;
          }));
        }
        return _results;
      });
      return void 0;
    });
    return void 0;
  });

}).call(this);
