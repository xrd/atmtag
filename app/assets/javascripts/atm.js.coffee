class AtmCtrl
        constructor: ( $scope, Bank, Preferences, $cookieStore, $location, $anchorScroll ) ->
                console.log "Loaded controller"

                $scope.attempted = false
                $scope.radius = 500
                $scope.metric = false

                $scope.$watch 'preferences.contribute', (newVal, oldVal) ->
                        if newVal != oldVal
                                console.log "channging contribution"
                                Preferences.set "contribute", newVal

                $scope.changeRadius = (count) ->
                        unless count
                                if radius = prompt "Enter the search radius (in meters)"
                                        $scope.radius = radius
                                        $scope.search()
                        else
                                $scope.radius = count
                                $scope.search()

                $scope.convert = (distance) ->
                        if $scope.metric
                                distance
                        else
                                distance*0.6

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
                                        request.radius = $scope.radius
                                        request.types = [ 'atm' ]
                                        service.nearbySearch request, (results, status) ->
                                                $scope.attempted = true
                                                if status == google.maps.places.PlacesServiceStatus.OK
                                                        $scope.results = results
                                                        $scope.calculateFeesForResults()
                                                        $scope.calculateDistances(position.coords)
                                                        $scope.message = ""
                                                        # Just shrink the search...
                                                        #$location.hash('results')
                                                        #$anchorScroll()
                                                else
                                                        $scope.message = "No results found"
                                                $scope.$digest()

                $scope.calculateDistances = (current) ->

                        toRad = (Value) ->
                                Value * Math.PI / 180

                        for result in $scope.results
                                lat1 = current.latitude
                                lon1 = current.longitude
                                lat2 = result.geometry.location.Ya
                                lon2 = result.geometry.location.Za
                                R = 6371; # km
                                dLat = toRad(lat2-lat1)
                                dLon = toRad(lon2-lon1)
                                lat1 = toRad(lat1)
                                lat2 = toRad(lat2)

                                a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                                        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
                                c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
                                d = R * c
                                result.distance = d

                $scope.help = (result) ->
                        if fee = prompt "Do you know the actual fee at this ATM? If so, please contribute the amount to improve estimations"
                                Bank.fee {}, { fee: fee }, (response) ->
                                        alert( "Thanks" )

                $scope.calculateFeesForResults = () ->
                        # Calculate cost
                        if $scope.banks.all and $scope.results
                                for bank in $scope.banks.all
                                        for gBank in $scope.results
                                                fee = calculateCost( gBank, bank )
                                                # vbc == validated by count
                                                vbc = bank.validated_by_count
                                                gBank.fees = { amount: fee, vbc: vbc }

                calculateCost = ( gBank, bank ) ->
                        # my withdrawal fee
                        mwf = $scope.preferences.mwf || 2.5
                        af = parseFloat( bank.averageFee ) || 2.5
                        rv = -1
                        # Lookup our banks, and assign fees
                        if $scope.preferences.banks
                                for myBank in $scope.preferences.banks
                                        # console.log "Got a match of our bank #{myBank.name} / #{gBank.name}!"
                                        if $scope.match( myBank.name, gBank.name )
                                                # console.log "Got a match of our bank #{myBank.name} / #{gBank.name}!"
                                                rv = 0.0
                        rv = ( af + mwf ) if -1 == rv
                        rv

                $scope.match = (bank_mixed, name_mixed) ->
                        return false unless bank_mixed and name_mixed

                        name = name_mixed.toLowerCase()
                        bank = bank_mixed.toLowerCase()
                        rv = false
                        rv = bank == name
                        unless rv
                                rv = ( -1 != name.indexOf( bank ) ) || ( -1 != bank.indexOf( name ) )
                        unless rv
                                nw_bank = bank.replace /\W+/, ''
                                nw_name = name.replace /\W+/, ''
                                rv = nw_name == nw_bank
                                unless rv
                                        rv = ( -1 != nw_name.indexOf( nw_bank ) ) || ( -1 != nw_bank.indexOf( nw_name ) )
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

                        Preferences.all (response) ->
                                $scope.allPrefs = response

                $scope.loadBanks = () ->
                        $scope.banks = {}
                        Bank.query (response) ->
                                $scope.banks.all = response

                $scope.addBank = () ->
                        $scope.preferences.banks ||= []
                        $scope.preferences.banks.push $scope.bank
                        Preferences.set "banks", $scope.preferences.banks
                        $scope.bank = undefined
                        # recalculate fees
                        $scope.calculateFeesForResults()

                $scope.initialize = () ->
                        $scope.loadBanks()
                        $scope.loadPreferences()
                        $scope.initializeMap()

                        # Remove our cloak
                        jQuery('.cloak').removeClass( 'hidden' ) if jQuery?

                $scope.removeBank = (bank) ->
                        if confirm "Remove bank #{bank.name} from your ATM card list?"
                                if -1 != toRemove = $scope.preferences.banks.indexOf( bank )
                                        $scope.preferences.banks.splice toRemove, 1
                                        Preferences.set "banks", $scope.preferences.banks
                                        $scope.calculateFeesForResults()

                $scope.initializeMap = () ->
                        if google? and google.maps?
                                mapOptions =
                                        center: new google.maps.LatLng(-34.397, 150.644),
                                        zoom: 8,
                                        mapTypeId: google.maps.MapTypeId.ROADMAP
                                $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

AtmCtrl.$inject = [ '$scope', 'Bank', 'Preferences', '$cookieStore', '$location', '$anchorScroll' ]
@AtmCtrl = AtmCtrl