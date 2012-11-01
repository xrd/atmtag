class AtmCtrl
        constructor: ( $scope, Bank, Preferences, $cookieStore ) ->
                console.log "Loaded controller"

                $scope.hideBanksMessage = () ->
                        Preferences.set 'hideBanksMessage', true
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
                        console.log "Hi there"

                loadContributorPreference = () ->
                        Preferences.get "contribute", (result) ->
                                console.log "Retrieving contribute #{result}"
                                $scope.preferences.contribute = result
                                unless result
                                        Preferences.set "contribute", "yes"
                                        $scope.preferences.contribute = "yes"
                                else
                                        console.log "Defined: #{$scope.preferences.contribute}"

                $scope.loadPreferences = () ->
                        console.log "Loading preferences"
                        $scope.preferences = {}
                        console.log "Getting banks message"
                        Preferences.get "hideBanksMessage", (response) ->
                                console.log "Retrieving preferences for banks: #{response}"
                                $scope.preferences.hideBanksMessage = response
                        console.log "Getting contributor message"
                        loadContributorPreference()
                        Preferences.get "banks", (response) ->
                                console.log "Retrieving preferences for all banks: #{response}"
                                $scope.preferences.banks = response

                $scope.loadBanks = () ->
                        $scope.banks = {}
                        $scope.banks.all = Bank.query()

                $scope.initialize = () ->
                        $scope.loadBanks()
                        $scope.loadPreferences()
                        $scope.initializeMap()

                        # Remove our cloak
                        jQuery('.cloak').removeClass( 'hidden' ) if jQuery?

                $scope.initializeMap = () ->
                        if google? and google.maps?
                                mapOptions = 
                                        center: new google.maps.LatLng(-34.397, 150.644),
                                        zoom: 8,
                                        mapTypeId: google.maps.MapTypeId.ROADMAP
                                $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

AtmCtrl.$inject = [ '$scope', 'Bank', 'Preferences', '$cookieStore' ]
@AtmCtrl = AtmCtrl