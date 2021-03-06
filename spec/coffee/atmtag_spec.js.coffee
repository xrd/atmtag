describe "AtmCtrl", () ->

        ctrl = undefined
        scope = undefined
        httpBackend = undefined
        mock = undefined
        prefs = undefined

        beforeEach( module( 'atmtag' ) )
        # Send back a string to make sure we catch errors with strings vs. integers
        mockPrompt = jasmine.createSpy().andReturn( "1.5" )
        window.prompt = mockPrompt

        store = {}
        setStore = (key, item) ->
                store[key] = item
        getStore = (key) ->
                store[key]
        prefs = { get: getStore , set: getStore, all: jasmine.createSpy() }

        beforeEach inject ($controller, $rootScope, $httpBackend ) ->
                httpBackend = $httpBackend
                $httpBackend.whenGET( /banks/ ).respond( banks )
                scope = $rootScope.$new();
                ctrl = $controller( AtmCtrl, { $scope: scope, Preferences: prefs } )
                spyOn( scope, 'search' ).andCallFake () ->
                        scope.results = results
                        scope.current =  lat: 50.0, lng: 50.0
                        scope.calculateFees()
                        scope.calculateDistances()

        afterEach ->
            httpBackend.verifyNoOutstandingExpectation()
            httpBackend.verifyNoOutstandingRequest()

        describe "#banks", () ->
                it "should load banks", () ->
                        expect( scope.banks ).toEqual undefined
                        scope.initialize()
                        httpBackend.flush()
                        expect( scope.banks.all[0].name ).toEqual "Bank1"

        describe "#preferences", () ->
                beforeEach () ->
                        scope.initialize()
                        httpBackend.flush()

                it "should store banks as preferences", () ->
                        expect( scope.banks.all[0].cost ).toEqual undefined
                        expect( scope.preferences.banks ).toEqual undefined
                        scope.addBank(scope.banks.all[1])
                        expect( scope.preferences.banks[0] ).toEqual scope.banks.all[1]

        describe "#costs", () ->
                beforeEach () ->
                        scope.initialize()
                        httpBackend.flush()

                it "should have banks with fees estimated", ->
                        scope.search()
                        scope.addBank( scope.banks.all[0] )

                it "should store distances once a search is performed", ->
                        expect( results[0].distance ).toBeFalsy()
                        scope.search()
                        expect( results[0].distance ).toBeTruthy()

                it "should find the lowest fee from all our cards", ->
                        scope.search()
                        scope.addBank( scope.banks.all[0] )
                        scope.addBank( scope.banks.all[1] )
                        scope.setBankFee( scope.preferences.banks[0] )
                        scope.setBankFee( scope.preferences.banks[1] )
                        # current fee should be default
                        expect( scope.lowestCardFee ).toEqual parseFloat( 1.5 )
                        scope.preferences.banks[1].myFee = 1.25
                        scope.calculateFees()
                        expect( scope.lowestCardFee ).toEqual 1.25

                it "should layer cost estimations based on selected banks", ->
                        scope.search()
                        scope.addBank( scope.banks.all[0] )
                        scope.setBankFee( scope.preferences.banks[0] )
                        expect(mockPrompt).toHaveBeenCalled()
                        expect( scope.preferences.banks[0].myFee ).toEqual 1.5
                        # First bank (in our preferences) should be zero
                        expect( scope.results[0].fees.amount ).toEqual 0
                        # Second bank, not in our preferences, should be our card fee plus their fee (1.5 + 2.5)
                        expect( scope.results[1].fees.amount ).toEqual 4

                it "should have a cost of zero if we have the bank in our banks", ->
                        scope.search()
                        scope.addBank( scope.banks.all[0] )
                        expect( scope.results[0].fees.amount ).toEqual 0

        describe "#match", () ->

                it "should match two banks with the same name", ->
                        expect( scope.match( "Chase", "Chase" ) ).toBeTruthy()

                it "should not match two banks with different names", ->
                        expect( scope.match( "Wells Fargo", "Chase" ) ).toBeFalsy()

                it "should match with different whitespace or punctuation", ->
                        expect( scope.match( "Chase   ", "Chase" ) ).toBeTruthy()

                it "should match partial names", ->
                        expect( scope.match( "Chase Bank", "Chase" ) ).toBeTruthy()
                        expect( scope.match( "Chase ", "Chase Bank" ) ).toBeTruthy()
                        expect( scope.match( "Chase       ", "Chase Bank           " ) ).toBeTruthy()

                it "should not match partial names with stuff in the middle", ->
                        expect( scope.match( "Chase XXX Bank", "Chase Bank" ) ).toBeFalsy()


                it "should match regardless of case", ->
                        expect( scope.match( "CHaSe", "ChASE BAnK" ) ).toBeTruthy()


        xdescribe "#preferences", () ->
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