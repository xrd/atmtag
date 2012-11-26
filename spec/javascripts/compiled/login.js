(function() {

  this.mod.controller('LoginCtrl', [
    '$scope', 'User', function($scope, User) {
      var temp_token;
      console.log("Inside login ctrl");
      $scope.user_token = $.cookie('user_token');
      $scope.status = "Starting";
      if (!$scope.user_token) {
        $scope.status = "No user token, getting it";
        if (temp_token = $.cookie('temp_token')) {
          $scope.status = "Got temp token";
          return User.create_from_token({
            token: temp_token
          }, {}, function(response) {
            $scope.status = "Created user from token";
            return $scope.user_token = response.token;
          });
        } else {
          return console.log("No cookies sent");
        }
      }
    }
  ]);

}).call(this);
