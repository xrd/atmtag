class AtmCtrl
        constructor: ( $scope, $cookieStore ) ->
                console.log "Loaded controller"
                
                $scope.getCurrentLocation = ( cb ) ->
                        if (navigator.geolocation)
                                navigator.geolocation.getCurrentPosition( cb );

                $scope.search = () ->
                        $scope.message = "Acquiring current location"
                        $scope.getCurrentLocation (position) ->
                                $scope.message = "Got current location, now searching local ATMs"
                                # x.innerHTML="Latitude: " + position.coords.latitude +
                                # "<br>Longitude: " + position.coords.longitude;
                                service = new google.maps.places.PlacesService($scope.map);
                                request = {}
                                request.location = new google.maps.LatLng( position.coords.latitude, position.coords.longitude )
                                request.radius = 500
                                request.types = [ 'atm' ]
                                service.nearbySearch request, (results, status) ->
                                        if status == google.maps.places.PlacesServiceStatus.OK
                                                $scope.results = []
                                                for result in results
                                                        $scope.results.push result
                                                $scope.message = "Got results"
                                        else
                                                $scope.message = "No results found"
                                        $scope.$digest()

                $scope.cost = (result) ->
                        return if $scope.preferences
                        rv = undefined
                        unless banks = $cookieStore.get( "banks" )
                                $scope.preferences = true
                        else
                                re = /wells/i
                                if re.test( result.name )
                                        rv = 10
                                else
                                        rv = 5.50
                        rv

                $scope.initialize = () ->
                        $scope.initializeMap()

                $scope.initializeMap = () ->
                        mapOptions = 
                                center: new google.maps.LatLng(-34.397, 150.644),
                                zoom: 8,
                                mapTypeId: google.maps.MapTypeId.ROADMAP
                        $scope.map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

AtmCtrl.$inject = [ '$scope', '$cookieStore' ]
@AtmCtrl = AtmCtrl