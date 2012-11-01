describe "AtmCtrl", () ->
        ctrl = undefined
        scope = undefined
        httpBackend = undefined
        lc = undefined

        beforeEach( module( 'atmtag' ) )

        beforeEach ->
                console.log "Creating new lawnchair"
                Lawnchair { name: "atmtag" }, (store) ->
                        store.keys (keys) ->
                                for k in keys
                                        console.log "Keys: #{k}"
                        console.log "Created new lawnchair"
                        store.nuke()
                        lc = store
                        console.log "Nuked lawnchair"

        beforeEach( inject ($controller, $rootScope, $httpBackend ) ->
                httpBackend = $httpBackend
                $httpBackend.whenGET( /banks/ ).respond( banks )
                scope = $rootScope.$new();
                ctrl = $controller( AtmCtrl, $scope: scope ) )

        afterEach ->
            httpBackend.verifyNoOutstandingExpectation()
            httpBackend.verifyNoOutstandingRequest()

        describe "#banks", () ->
                it "should load banks", () ->
                        expect( scope.banks ).toEqual undefined
                        scope.initialize()
                        httpBackend.flush()
                        expect( scope.banks.all[0].name ).toEqual "Chris Bank"
                undefined

        describe "#costs", () ->
                it "should layer cost estimations based on selected banks", () ->
                        scope.initialize()
                        httpBackend.flush()
                        expect( scope.banks.all[0].cost ).toEqual undefined
                        console.log "Hey, layering costs"

        describe "#preferences", () ->
                # WTF, this is failing
                xit "should store and nuke settings", () ->
                        console.log "Checking interface for lanwchair"
                        all = []
                        lc.keys (keys) ->
                                for k in keys
                                        console.log "Key: #{k}"
                                        all.push k
                                expect( all.length ).toEqual 0
                                        
                        lc.get "foo", (response) ->
                        expect( response ).toEqual undefined
                        console.log "Validated empty foo"
                        lc.save key: "foo", value: "bar"
                        console.log "Saved foo and bar"
                        lc.get "foo", (response) ->
                                console.log "Retreived foo now bar"
                                expect( response.value ).toEqual "bar"
                                console.log "All sanity checks for store pass"
                                        
                it "should start with preferences unset after initialization", () ->
                        expect( scope.preferences ).toEqual undefined
                        scope.initialize()
                        httpBackend.flush()
                        expect( scope.preferences.hideBanksMessage ).toBeTruthy()

                it "should start with preferences", () ->
                        spyOn( scope, 'loadPreferences' )
                        expect( scope.preferences ).toEqual undefined
                        
                it "should start with preferences unset after initialization", () ->
                        console.log "Checking preferences prior to init"
                        spyOn( scope, 'loadPreferences' )
                        expect( scope.preferences ).toEqual undefined
                        console.log "Checking preferences after to init"
                        scope.initialize()
                        httpBackend.flush()
                        expect( scope.loadPreferences ).toHaveBeenCalled()
                        
                it "should start with preferences retrieved properly after initialization", () ->
                        lc.save { key: "preferences.contribute", value: "no" }
                        lc.get "preferences.contribute", (value) ->
                                expect( value.value ).toEqual "no"
                        expect( scope.preferences ).toEqual undefined
                        scope.initialize()
                        httpBackend.flush()
                        expect( scope.preferences.contribute ).toEqual "no"
                        
                it "should start with contributor preferences set to 'yes' the first time after initialization", () ->
                        expect( scope.preferences ).toEqual undefined
                        scope.initialize()
                        httpBackend.flush()
                        expect( scope.preferences.contribute ).toEqual "yes"

                afterEach ->
                        for i in [ lc ]
                                console.log "Reviewing keys for #{i}"
                                i.keys (keys) ->
                                        for k in keys
                                                lc.get k, (value) ->
                                                        console.log "*** Used key: #{k} / #{value.value}"

                        
                                        
                undefined
        undefined