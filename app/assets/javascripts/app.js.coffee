mod = angular.module "atmtag", [ 'ngCookies', 'ngResource', 'ui' ]
@mod = mod

mod.factory 'Bank', [ '$resource', ($resource) ->
        $resource '/banks/:id/:action', {},
                fee: { method: 'POST', params: { action: "fee" }, isArray: false }
        ]

mod.factory 'Preferences', [ (store) ->
        console.log "Creating store service (lawnchair)"
        store = {}
        Lawnchair (lawnchair) ->
                # lawnchair.nuke()
                store = {}
                store.get = ( key, cb ) ->
                        console.log "Getting preference for: #{key}"
                        lawnchair.get key, (response) ->
                                value = response.value if response?
                                console.log "Got #{key} => #{value}"
                                cb(value)
                store.set = ( key, value ) ->
                        console.log "Setting preference for: #{key} to #{value}"
                        lawnchair.save key: key, value: value
                store.all = (cb) ->
                        lawnchair.all(cb)
        store
        ]
