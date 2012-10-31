describe "An atm controller", () ->
        
        @ctrl = undefined
        @scope = undefined
        @httpBackend = undefined

        beforeEach( module( 'atmtag' ) )

        beforeEach( inject ($controller, $rootScope, $httpBackend, Store ) ->
                @httpBackend = $httpBackend
                @httpBackend.whenGET(/.*/).respond( banks )
                @scope = $rootScope.$new();
                @ctrl = $controller( AtmCtrl, $scope: @scope, Store: Store ) )

        beforeEach ->
                new Lawnchair { name: 'atmtag' }, () ->
                        @nuke()

        afterEach ->
            @httpBackend.verifyNoOutstandingExpectation()
            @httpBackend.verifyNoOutstandingRequest()

        it "should load banks", () ->
                expect( @scope.banks.all ).toEqual {}
                @scope.intialize()
                @httpBackend.flush()
                expect( @scope.banks.all[0].name ).toEqual "Chris Bank"

        it "should start with preferences unset", () ->
                $injector = angular.injector([ 'atmtag' ]);
                store = $injector.get( 'Store' );
                expect( @scope.preferences ).toEqual undefined
                @scope.initialize()
                @httpBackend.flush()
                # expect( @scope.preferences.contribute ).toEqual "yes"
                
                