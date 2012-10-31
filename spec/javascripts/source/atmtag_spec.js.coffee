describe "An atm controller", () ->
        
        ctrl = undefined
        scope = undefined
        httpBackend = undefined

        beforeEach( module( 'atmtag' ) )

        beforeEach( inject ($controller, $rootScope, $httpBackend) ->
                httpBackend = $httpBackend
                httpBackend.whenGET(/.*/).respond( banks )
                scope = $rootScope.$new();
                ctrl = $controller( AtmCtrl, $scope: scope ) )

        it "should be able to create itself", () ->
                expect(scope.status).toEqual 'loading'
                
