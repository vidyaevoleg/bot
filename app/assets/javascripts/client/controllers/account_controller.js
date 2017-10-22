APP.controller('AccountCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  $scope.account = gon.account;
  $scope.sessions = gon.sessions;


}]);
