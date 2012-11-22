@mod.controller 'LoginCtrl', [ '$scope', 'User', ($scope, User) ->
        console.log "Inside login ctrl"
        $scope.user_token = $.cookie 'user_token'

        $scope.status = "Starting"

        unless $scope.user_token
                $scope.status = "No user token, getting it"
                if temp_token = $.cookie 'temp_token'
                        $scope.status = "Got temp token"
                        User.create_from_token { token: temp_token }, {}, (response) ->
                                $scope.status= "Created user from token"
                                $scope.user_token = response.token
                else
                        console.log "No cookies sent"
        ]