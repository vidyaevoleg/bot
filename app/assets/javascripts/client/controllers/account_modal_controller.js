APP.controller('AccountModalCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  var scope = modalService.getScope();

  $scope.account = scope.account;

  $scope.createAccount = function () {
    submit();
  }

  $scope.closeModal = modalService.close;

  function submit() {
    $scope.errors = {};
    API.accounts.createOrUpdate($scope.account).then(function (res) {
      $scope.account = res.data;
      Notification.success({title: 'Сохранено'});
    }, function (error) {
      $scope.errors = error.errors;
    })
  }

}]);
