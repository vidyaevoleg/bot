APP.controller('TemplateCtrl', ['$scope', 'modalService',  function ($scope, modalService) {
  $scope.template = gon.template;
  $scope.sessions = gon.sessions;
  $scope.openReports = function () {
    modalService.init('client/templates/reports_modal.html', 'ReportsModalCtrl', {template: $scope.template}, 'lg');
  }

  $scope.editTemplate = function () {
    modalService.init('client/templates/template_modal.html', 'TemplateModalCtrl', {template: $scope.template}, 'lg');
  };

}]);
