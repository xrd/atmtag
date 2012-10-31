class AtmCtrl
        constructor: ( $scope, Bank, Store, $cookieStore ) ->
                console.log "Loaded controller"

                $scope.banks = {}
                $scope.banks.all = Bank.query()
                #                $scope.banks.all = [ { name: 'Foo', state: 'CA' }, { name: "Bar", state: 'OR' } ]

                $scope.hideBanksMessage = () ->
                        Store.save 'hideBanksMessage': true
                        $scope.preferences.hideBanksMessage = true
                                                                                                       
                $scope.getCurrentLocation = ( cb ) ->
                        if (navigator.geolocation)
                                navigator.geolocation.getCurrentPosition( cb );

                $scope.search = () ->
                        $scope.message = "Acquiring current location"
                        $scope.getCurrentLocation (position) ->
                                $scope.message = "Got current location, now searching local ATMs"
                                # x.innerHTML="Latitude: " + position.coords.latitude +
                                # "<br>Longitude: " + position.coords.longitude;
                                if google? and google.maps?
                                        service = new google.maps.places.PlacesService($scope.map);
                                        request = {}
                                        request.location = new google.maps.LatLng( position.coords.latitude, position.coords.longitude )
                                        request.radius = 500
                                        request.types = [ 'atm' ]
                                        service.nearbySearch request, (results, status) ->
                                                if status == google.maps.places.PlacesServiceStatus.OK
                                                        $scope.results = []
                                                        for result in results
                                                                # Calculate cost
                                                                for bank in $scope.banks.all
                                                                        fee = calculateCost( bank.average_fee )
                                                                        # vbc == validated by count
                                                                        vbc = bank.validated_by_count
                                                                        result.fees = { amount: fee, vbc: vbc }
                                                                $scope.results.push result
                                                        $scope.message = "Got results"
                                                else
                                                        $scope.message = "No results found"
                                                $scope.$digest()

                calculateCost = ( averageFee, name ) ->
                        # my withdrawal fee
                        mwf = $scope.preferences.mwf
                        af = parseFloat( averageFee ) || 0.0
                        rv = -1
                        # Lookup our banks, and assign fees
                        if $scope.preferences.banks
                                for bank in $scope.preferences.banks
                                        if match( bank, name )
                                                rv = 0.0
                        rv = ( af + mwf ) if -1 == rv
                        rv

                $scope.chooseBanks = () ->

                loadContributorPreference = () ->
                        Store.get "contribute", (result) ->
                                unless $scope.preferences.contribute = result
                                        Store.save "contribute": "yes"

                $scope.initialize = () ->
                        $scope.preferences = {}
                        Store.get "hideBanksMessage", (response) ->
                                $scope.preferences.hideBanksMessage = response
                        loadContributorPreference()
                        Store.get "banks", (response) ->
                                $scope.preferences.banks = response
                        $scope.initializeMap()

                        # Remove our cloak
                        $('.cloak').removeClass( 'hidden' )

                $scope.initializeMap = () ->
                        if google? and google.maps?
                                mapOptions = 
                                        center: new google.maps.LatLng(-34.397, 150.644),
                                        zoom: 8,
                                        mapTypeId: google.maps.MapTypeId.ROADMAP
                                $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

AtmCtrl.$inject = [ '$scope', 'Bank', 'Store', '$cookieStore' ]
@AtmCtrl = AtmCtrl