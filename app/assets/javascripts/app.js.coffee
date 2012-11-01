mod = angular.module "atmtag", [ 'ngCookies', 'ngResource' ]
@mod = mod

mod.factory 'Bank', [ '$resource', ($resource) ->
        $resource '/banks/:id/:action', {}, {}
        ]

mod.factory 'Preferences', [ (store) ->
        console.log "Creating store service (lawnchair)"
        store = {}
        Lawnchair { name: 'atmtag' }, (lawnchair) ->
                store = {}
                store.get = ( key, cb ) ->
                        console.log "Getting preference for: #{key}"
                        lawnchair.get "preferences."+key, (response) ->
                                value = response[key].value if response? and response[key]
                                console.log "Got preferences.#{key} => #{value}"
                                cb(value)
                store.set = ( key, value ) ->
                        console.log "Setting preference for: #{key} to #{value}"
                        lawnchair.get "preferences."+key, (response) ->
                                response = {} unless response
                                response[key] = value
                                lawnchair.save response
        store
        ]                
