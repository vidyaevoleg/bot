APP.controller('DownloadStatModalCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  // $scope.sheets = ['all', 'days', 'markets', 'spreads', 'market volumes', 'config', 'time'];
  $scope.sheets = ['all', 'days'];

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
  }

}]);
