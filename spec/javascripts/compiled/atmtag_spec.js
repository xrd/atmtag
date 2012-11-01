(function() {

  describe("AtmCtrl", function() {
    var Store;
    this.ctrl = void 0;
    this.scope = void 0;
    this.httpBackend = void 0;
    Store = void 0;
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
        Store = store;
        return console.log("Nuked lawnchair");
      });
    });
    beforeEach(inject(function($controller, $rootScope, $httpBackend) {
      this.httpBackend = $httpBackend;
      $httpBackend.whenGET(/banks/).respond(banks);
      this.scope = $rootScope.$new();
      return this.ctrl = $controller(AtmCtrl, {
        $scope: this.scope
      });
    }));
    afterEach(function() {
      this.httpBackend.verifyNoOutstandingExpectation();
      return this.httpBackend.verifyNoOutstandingRequest();
    });
    describe("#banks", function() {
      return it("should load banks", function() {
        expect(this.scope.banks).toEqual(void 0);
        this.scope.initialize();
        this.httpBackend.flush();
        return expect(this.scope.banks.all[0].name).toEqual("Chris Bank");
      });
    });
    describe("#costs", function() {
      return it("should layer cost estimations based on selected banks", function() {
        this.scope.initialize();
        expect(this.scope.banks.all[0].cost).toEqual(void 0);
        return console.log("Hey, layering costs");
      });
    });
    return describe("#preferences", function() {
      it("should store and nuke settings", function() {
        var all;
        console.log("Checking interface for lanwchair");
        all = [];
        Store.keys(function(keys) {
          var k, _i, _len;
          for (_i = 0, _len = keys.length; _i < _len; _i++) {
            k = keys[_i];
            console.log("Key: " + k);
            all.push(k);
          }
          return expect(all.length).toEqual(0);
        });
        Store.get("foo", function(response) {});
        expect(response).toEqual(void 0);
        console.log("Validated empty foo");
        Store.save({
          key: "foo",
          value: "bar"
        });
        console.log("Saved foo and bar");
        return Store.get("foo", function(response) {
          console.log("Retreived foo now bar");
          expect(response.value).toEqual("bar");
          return console.log("All sanity checks for store pass");
        });
      });
      it("should start with preferences", function() {
        spyOn(this.scope, 'loadPreferences');
        return expect(this.scope.preferences).toEqual(void 0);
      });
      it("should start with preferences unset after initialization", function() {
        console.log("Checking preferences prior to init");
        spyOn(this.scope, 'loadPreferences');
        expect(this.scope.preferences).toEqual(void 0);
        console.log("Checking preferences after to init");
        this.scope.initialize();
        this.httpBackend.flush();
        return expect(this.scope.loadPreferences).toHaveBeenCalled();
      });
      it("should start with preferences retrieved properly after initialization", function() {
        Store.save({
          key: "preferences.contribute",
          value: "no"
        });
        expect(this.scope.preferences).toEqual(void 0);
        this.scope.initialize();
        this.httpBackend.flush();
        return expect(this.scope.preferences.contribute).toEqual("no");
      });
      return it("should start with contributor preferences set to 'yes' the first time after initialization", function() {
        expect(this.scope.preferences).toEqual(void 0);
        this.scope.initialize();
        this.httpBackend.flush();
        return expect(this.scope.preferences.contribute).toEqual("yes");
      });
    });
  });

}).call(this);
