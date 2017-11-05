APP.controller('ReportsModalCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  var scope = modalService.getScope();
  $scope.template = scope.template;
  $scope.closeModal = modalService.close;
}]);
