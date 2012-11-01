describe "AtmCtrl", () ->
        @ctrl = undefined
        @scope = undefined
        @httpBackend = undefined
        Store = undefined

        beforeEach( module( 'atmtag' ) )

        beforeEach ->
                console.log "Creating new lawnchair"
                Lawnchair { name: "atmtag" }, (store) ->
                        store.keys (keys) ->
                                for k in keys
                                        console.log "Keys: #{k}"
                        console.log "Created new lawnchair"
                        store.nuke()
                        Store = store
                        console.log "Nuked lawnchair"

        beforeEach( inject ($controller, $rootScope, $httpBackend ) ->
                @httpBackend = $httpBackend
                $httpBackend.whenGET( /banks/ ).respond( banks )
                @scope = $rootScope.$new();
                @ctrl = $controller( AtmCtrl, $scope: @scope ) )

        afterEach ->
            @httpBackend.verifyNoOutstandingExpectation()
            @httpBackend.verifyNoOutstandingRequest()

        describe "#banks", () ->
                it "should load banks", () ->
                        expect( @scope.banks ).toEqual undefined
                        @scope.initialize()
                        @httpBackend.flush()
                        expect( @scope.banks.all[0].name ).toEqual "Chris Bank"

        describe "#costs", () ->
                it "should layer cost estimations based on selected banks", () ->
                        @scope.initialize()
                        expect( @scope.banks.all[0].cost ).toEqual undefined
                        console.log "Hey, layering costs"

        describe "#preferences", () ->
                it "should store and nuke settings", () ->
                        console.log "Checking interface for lanwchair"
                        all = []
                        Store.keys (keys) ->
                                for k in keys
                                        console.log "Key: #{k}"
                                        all.push k
                                expect( all.length ).toEqual 0
                                        
                        Store.get "foo", (response) ->
                        expect( response ).toEqual undefined
                        console.log "Validated empty foo"
                        Store.save key: "foo", value: "bar"
                        console.log "Saved foo and bar"
                        Store.get "foo", (response) ->
                                console.log "Retreived foo now bar"
                                expect( response.value ).toEqual "bar"
                                console.log "All sanity checks for store pass"
                                        
                it "should start with preferences", () ->
                        spyOn( @scope, 'loadPreferences' )
                        expect( @scope.preferences ).toEqual undefined
                        
                it "should start with preferences unset after initialization", () ->
                        console.log "Checking preferences prior to init"
                        spyOn( @scope, 'loadPreferences' )
                        expect( @scope.preferences ).toEqual undefined
                        console.log "Checking preferences after to init"
                        @scope.initialize()
                        @httpBackend.flush()
                        expect( @scope.loadPreferences ).toHaveBeenCalled()
                        
                it "should start with preferences retrieved properly after initialization", () ->
                        Store.save { key: "preferences.contribute", value: "no" }
                        expect( @scope.preferences ).toEqual undefined
                        @scope.initialize()
                        @httpBackend.flush()
                        expect( @scope.preferences.contribute ).toEqual "no"
                        
                it "should start with contributor preferences set to 'yes' the first time after initialization", () ->
                        expect( @scope.preferences ).toEqual undefined
                        @scope.initialize()
                        @httpBackend.flush()
                        expect( @scope.preferences.contribute ).toEqual "yes"
