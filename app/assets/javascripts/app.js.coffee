mod = angular.module "atmtag", [ 'ngCookies', 'ngResource' ]
@mod = mod

mod.factory 'Bank', [ '$resource', ($resource) ->
        $resource '/banks/:id/:action', {}, {}
        ]
