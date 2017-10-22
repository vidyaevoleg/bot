APP.controller('DashboardCtrl', ['API', '$scope', 'modalService', function (API, $scope, modalService) {
  $scope.accounts = gon.current_user.accounts;

  // if (account) {
  //   API.accounts.getSessions(account.id).then(function(res) {
  //     $scope.sessions = res.data;
  //   });
  // }

  $scope.addNewAccount = function () {
    modalService.init('client/templates/account_modal.html', 'AccountModalCtrl', {});
  };

  $scope.editAccount = function (account) {
    modalService.init('client/templates/account_modal.html', 'AccountModalCtrl', {account: account}, 'lg');
  };

  $scope.addNewTemplate = function (account) {
    var example = Object.assign({}, account.templates[0]);
    example.id = null; example.currency = null; example.account_id = account.id;
    modalService.init('client/templates/template_modal.html', 'TemplateModalCtrl', {template: example})
  };

  $scope.editTemplate = function (template) {
    modalService.init('client/templates/template_modal.html', 'TemplateModalCtrl', {template: template}, 'lg');
  };

  $scope.deleteAccount = function (index, id) {
    API.accounts.delete(id).then(function (res) {
      $scope.accounts.splice(index, 1);
    }, function (err) {
      console.error(error);
    })
  };

}]);
