(function() {

  this.mod.controller('LoginCtrl', [
    '$scope', 'User', function($scope, User) {
      var temp_token;
      console.log("Inside login ctrl");
      $scope.user_token = $.cookie('user_token');
      if (!$scope.user_token) {
        if (temp_token = $.cookie('temp_token')) {
          return User.create_from_token({
            token: temp_token
          }, {}, function(response) {
            return $scope.user_token = response.token;
          });
        } else {
          return console.log("No cookies sent");
        }
      }
    }
  ]);

}).call(this);
