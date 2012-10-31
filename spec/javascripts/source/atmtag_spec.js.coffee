describe "An atm controller", () ->
        
        @ctrl = undefined
        @scope = undefined
        @httpBackend = undefined

        beforeEach( module( 'atmtag' ) )

        beforeEach( inject ($controller, $rootScope, $httpBackend) ->
                @httpBackend = $httpBackend
                @httpBackend.whenGET(/.*/).respond( banks )
                @scope = $rootScope.$new();
                @ctrl = $controller( AtmCtrl, $scope: @scope ) )

        afterEach ->
            @httpBackend.verifyNoOutstandingExpectation()
            @httpBackend.verifyNoOutstandingRequest()

        it "should load banks", () ->
                expect( @scope.banks.all ).toEqual {}
                @httpBackend.flush()
                expect( @scope.banks.all[0].name ).toEqual "Chris Bank"
                
