APP.controller('DashboardCtrl', ['API', '$scope', 'modalService', function (API, $scope, modalService) {
  $scope.accounts = gon.current_user.accounts;

  var account = $scope.accounts[0];

  if (account) {
    API.accounts.getSessions(account.id).then(function(res) {
      $scope.sessions = res.data;
    });
  }

  $scope.addNewAccount = function () {
    modalService.init('client/templates/account_modal.html', 'AccountModalCtrl', {});
  };

  $scope.editAccount = function (account) {
    var sessions = $scope.sessions.filter(function (session) {
      return session.account_id == account.id;
    });
    modalService.init('client/templates/account_modal.html', 'AccountModalCtrl', {account: account, sessions: sessions}, 'lg');
  };

  $scope.deleteAccount = function (index, id) {
    API.accounts.delete(id).then(function (res) {
      $scope.account.splice(index, 1);
    }, function (err) {
      console.error(error);
    })
  };

}]);
