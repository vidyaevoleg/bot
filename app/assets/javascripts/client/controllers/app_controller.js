APP.controller('AppCtrl', ['$scope', 'modalService',  function ($scope, modalService) {
  $scope.downloadStat = function () {
    modalService.init('client/templates/download_stat_modal.html', 'DownloadStatModalCtrl', {current_user: gon.current_user}, 'lg');
  }
}]);
