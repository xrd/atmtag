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
        $.cookie.json = true
        store = {}
        store.get = ( key ) ->
                $.cookie key

        store.set = ( key, value ) ->
                $.cookie key, value, expires: 365*10
                console.log "Setting preference for: #{key} to #{value}"
        store
        ]
