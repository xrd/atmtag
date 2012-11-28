mod = angular.module "atmtag", [ 'ngCookies', 'ngResource', 'ui' ]
@mod = mod

mod.factory 'Bank', [ '$resource', ($resource) ->
        $resource '/banks/:id/:action', {},
                add_estimation: { method: 'POST', params: { action: "add_estimation" }, isArray: false }
                estimations: { method: 'GET', params: { action: 'get_estimations'}, isArray: true }
        ]

mod.factory 'User', [ '$resource', ($resource) ->
        $resource '/users/:id/:action', {},
                create_from_token: { method: 'POST', params: { action: "create_from_token" }, isArray: false }
        ]


mod.config [ '$httpProvider', ($httpProvider) ->
        if $?
                authToken = $('meta[name="csrf-token"]').attr('content')
                $httpProvider.defaults.headers.common[ 'X-CSRF-TOKEN' ] = authToken
        ]

mod.factory 'Preferences', [ (store) ->
        console.log "Creating store service (lawnchair)"
        store = {}
        Lawnchair name: 'atmtag', (lawnchair) ->
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
