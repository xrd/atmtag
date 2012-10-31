(function() {

  describe("An atm controller", function() {
    var ctrl, httpBackend, scope;
    ctrl = void 0;
    scope = void 0;
    httpBackend = void 0;
    beforeEach(module('atmtag'));
    beforeEach(inject(function($controller, $rootScope, $httpBackend) {
      httpBackend = $httpBackend;
      httpBackend.whenGET(/.*/).respond(banks);
      scope = $rootScope.$new();
      return ctrl = $controller(AtmCtrl, {
        $scope: scope
      });
    }));
    return it("should be able to create itself", function() {
      return expect(scope.status).toEqual('loading');
    });
  });

}).call(this);
