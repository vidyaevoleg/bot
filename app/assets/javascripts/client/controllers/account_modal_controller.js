APP.controller('AccountModalCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  var scope = modalService.getScope();

  $scope.account = scope.account || {
    provider: 'bittrex'
  };

  $scope.sessions = scope.sessions || [];

  $scope.createAccount = function () {
    submit();
  }

  $scope.updateAccount = function () {
    submit();
  }

  $scope.ui = {
    needStart: function () {
      var lastSession = $scope.sessions[0];
      var template = $scope.account.template
      var interval = template && template.interval;
      var secs = lastSession && parseInt((new Date() - new Date(lastSession.created_at)) / 1000)
      return interval && (!lastSession || (secs > interval));
    }
  }

  $scope.start = function () {
    API.accounts.start($scope.account.id).then(function () {
      window.location.reload();
    }, function error(err) {
      console.log(err);
    });
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
