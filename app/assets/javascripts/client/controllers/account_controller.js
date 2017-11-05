APP.controller('AccountCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  $scope.account = gon.account;
  $scope.sessions = gon.sessions;

  $scope.editTemplate = function (template) {
    modalService.init('client/templates/template_modal.html', 'TemplateModalCtrl', {template: template}, 'lg');
  };

  $scope.wallets = gon.wallets.filter(function(item) { return item.available > 0});
  $scope.finalSum = $scope.wallets.map(function (w) {
    return w.available_currency;
  }).reduce(function (a, b) {
    return parseFloat(a) + parseFloat(b);
  }, 0);

}]);
