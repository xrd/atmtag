(function() {

  describe("An atm controller", function() {
    this.ctrl = void 0;
    this.scope = void 0;
    this.httpBackend = void 0;
    beforeEach(module('atmtag'));
    beforeEach(inject(function($controller, $rootScope, $httpBackend, Store) {
      this.httpBackend = $httpBackend;
      this.httpBackend.whenGET(/.*/).respond(banks);
      this.scope = $rootScope.$new();
      return this.ctrl = $controller(AtmCtrl, {
        $scope: this.scope,
        Store: Store
      });
    }));
    beforeEach(function() {
      return new Lawnchair({
        name: 'atmtag'
      }, function() {
        return this.nuke();
      });
    });
    afterEach(function() {
      this.httpBackend.verifyNoOutstandingExpectation();
      return this.httpBackend.verifyNoOutstandingRequest();
    });
    it("should load banks", function() {
      expect(this.scope.banks.all).toEqual({});
      this.scope.intialize();
      this.httpBackend.flush();
      return expect(this.scope.banks.all[0].name).toEqual("Chris Bank");
    });
    return it("should start with preferences unset", function() {
      var $injector, store;
      $injector = angular.injector(['atmtag']);
      store = $injector.get('Store');
      expect(this.scope.preferences).toEqual(void 0);
      this.scope.initialize();
      return this.httpBackend.flush();
    });
  });

}).call(this);
