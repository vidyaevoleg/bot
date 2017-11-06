APP.controller('DownloadStatModalCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  var scope = modalService.getScope();
  var configs = Object.keys(scope.current_user.accounts[0].templates[0]);
  _.remove(configs, function (c) {return ['id', '$$hashKey', 'coins', 'currency', 'need_restart', 'white_list', 'black_list'].includes(c)});
  $scope.configs = configs;
  $scope.sheets = ['all', 'days', 'markets', 'spreads', 'volumes', 'configs', 'times'];

  $scope.params = {
    from: new Date(new Date().setDate(new Date().getDate()-1)),
    to: new Date()
  };

  $scope.ui = {
    setupIsValid: function () {
      return $scope.params.from && $scope.params.to && $scope.params.currency;
    }
  };

  $scope.downloadSheet = function (sheet) {
    var options = Object.assign({}, $scope.params);
    options.from = options.from.toString();
    options.to = options.to.toString();
    var sheetUrl = '/stat/' + sheet + "?" + $.param($scope.params);
    window.location.replace(sheetUrl);
  };

  $scope.closeModal = modalService.close;


}]);
