class AtmCtrl
        constructor: ( $scope, Bank, Preferences, $cookieStore, $location, $anchorScroll ) ->
                console.log "Loaded controller"
                $scope.maps = {}
                $scope.attempted = false
                $scope.radius = 500
                $scope.metric = false

                $scope.$watch 'preferences.contribute', (newVal, oldVal) ->
                        if newVal != oldVal
                                console.log "channging contribution"
                                Preferences.set "contribute", newVal

                $scope.changeRadius = (count) ->
                        unless count
                                if radius = window.prompt "Enter the search radius (in #{if $scope.metric then 'km' else 'mi'})"
                                        $scope.radius = radius * 1000
                                        $scope.radius *= 0.6 unless $scope.metric
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
                        $scope.results = undefined
                        $scope.message = "Acquiring current location"
                        $scope.getCurrentLocation (position) ->
                                $scope.message = "Got current location, now searching local ATMs"
                                # x.innerHTML="Latitude: " + position.coords.latitude +
                                # "<br>Longitude: " + position.coords.longitude;
                                if google? and google.maps?
                                        service = new google.maps.places.PlacesService($scope.map);
                                        request = {}
                                        $scope.current = lat: position.coords.latitude, lng: position.coords.longitude
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
                                lat2 = result.geometry.location.lat()
                                lon2 = result.geometry.location.lng()
                                console.log "Lat/lng: #{lat1}/#{lon1} vs. #{lat2}/#{lon2}"
                                R = 6371; # km
                                dLat = toRad(lat2-lat1)
                                dLon = toRad(lon2-lon1)
                                lat1 = toRad(lat1)
                                lat2 = toRad(lat2)

                                a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                                        Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
                                c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
                                d = R * c
                                console.log "Distance: #{d}"
                                result.distance = d

                $scope.iob = (expanded) ->
                        if expanded then "expanded" else "tight"

                $scope.help = (result) ->
                        if fee = window.prompt "Do you know the actual fee at this ATM? If so, please contribute the amount to improve estimations"
                                lat = result.geometry.location.lat
                                lng = result.geometry.location.lng
                                name = result.name
                                Bank.add_estimation {}, { estimation: { fee: fee, lat: lat, lng: lng, name: name, uid: result.id } }, (response) ->
                                        if "ok" == response.status
                                                result.
                                                console.log "Registered result"
                                                $scope.calculateFeesForResults()
                                        else
                                                console.log "Error"


                $scope.setBankFee = (bank) ->
                        if fee = window.prompt "What fee do you pay at this bank?"
                                bank.myFee = fee

                $scope.calculateFeesForResults = () ->
                        # Calculate cost
                        if $scope.banks.all and $scope.results
                                console.log "Have banks and results loaded"

                                for bank in $scope.banks.all
                                        console.log "Checking #{bank.name} in all"
                                        for gBank in $scope.results
                                                fee = calculateCost( gBank, bank )
                                                # vbc == validated by count
                                                vbc = bank.validated_by_count
                                                gBank.fees = { amount: fee, vbc: vbc }

                calculateCost = ( gBank, bank ) ->
                        # my withdrawal fee
                        mwf = $scope.preferences.mwf || 2.5
                        af = bank.myFee || parseFloat( bank.averageFee ) || 2.5
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
                        $scope.banks.chooser = true
                        $('.modal').css( left: '300px', top: '250px', width: '280px' )

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

                $scope.addBank = (bank) ->
                        $scope.preferences.banks ||= []
                        $scope.preferences.banks.push bank
                        Preferences.set "banks", $scope.preferences.banks
                        $scope.bank = undefined
                        # recalculate fees
                        $scope.calculateFeesForResults()

                $scope.verifyUser = () ->
                        console.log "Inside user check"

                $scope.initialize = () ->
                        $scope.verifyUser()

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

                $scope.focusOnMap = (item) ->
                        if google? and google.maps?
                                center = new google.maps.LatLng( item.geometry.location.lat(), item.geometry.location.lng() )
                                current = new google.maps.LatLng( $scope.current.lat, $scope.current.lng )
                                mapOptions =
                                        center: center
                                        zoom: 15,
                                        mapTypeId: google.maps.MapTypeId.ROADMAP
                                $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
                                cur = new google.maps.Marker
                                          position: current
                                          map: $scope.map,
                                          icon: '/assets/yellow_MarkerA.png'

                                atm = new google.maps.Marker
                                          position: center,
                                          map: $scope.map,
                                          icon: '/assets/green_MarkerZ.png'
                                $scope.maps.atm = item
                                $scope.maps.display = true

                $scope.initializeMap = () ->
                        if google? and google.maps?
                                center = new google.maps.LatLng( 50, 50 )
                                mapOptions =
                                        center: center
                                        zoom: 15,
                                        mapTypeId: google.maps.MapTypeId.ROADMAP
                                $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
                        console.log "Created map"

AtmCtrl.$inject = [ '$scope', 'Bank', 'Preferences', '$cookieStore', '$location', '$anchorScroll' ]
@AtmCtrl = AtmCtrl