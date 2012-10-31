(function() {

  describe("An atm controller", function() {
    this.ctrl = void 0;
    this.scope = void 0;
    this.httpBackend = void 0;
    beforeEach(module('atmtag'));
    beforeEach(inject(function($controller, $rootScope, $httpBackend) {
      this.httpBackend = $httpBackend;
      this.httpBackend.whenGET(/.*/).respond(banks);
      this.scope = $rootScope.$new();
      return this.ctrl = $controller(AtmCtrl, {
        $scope: this.scope
      });
    }));
    afterEach(function() {
      this.httpBackend.verifyNoOutstandingExpectation();
      return this.httpBackend.verifyNoOutstandingRequest();
    });
    return it("should load banks", function() {
      expect(this.scope.banks.all).toEqual({});
      this.httpBackend.flush();
      return expect(this.scope.banks.all[0].name).toEqual("Chris Bank");
    });
  });

}).call(this);
