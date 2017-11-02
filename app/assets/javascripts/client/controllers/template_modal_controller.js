APP.controller('TemplateModalCtrl', ['API', '$scope', 'modalService', 'Notification', function (API, $scope, modalService, Notification) {
  var scope = modalService.getScope();
  $scope.template = scope.template;
  $scope.closeModal = modalService.close;

  $scope.createTemplate = function () {
    submit();
  }

  $scope.updateTemplate = function () {
    submit();
  }

  $scope.restart = function () {
    API.templates.start($scope.template.id).then(function () {
      window.location.reload();
    }, function error(err) {
      console.log(err);
    });
  }

  $scope.off = function () {
    API.templates.off($scope.template.id).then(function () {
      window.location.reload();
    }, function (err) {
      console.log(err);
    })
  }

  $scope.deleteTemplate = function () {
    API.templates.delete($scope.template.id).then(function (res) {
      window.location.reload();
    }, function (err) {
      Notification.error({title: JSON.stringify(err.data.errors)});
    })
  };

  function submit() {
    $scope.errors = {};
    API.templates.createOrUpdate($scope.template).then(function (res) {
      $scope.template = res.data;
      Notification.success({title: 'Сохранено'});
    }, function (error) {
      Notification.error({title: JSON.stringify(error.data.errors)});
      $scope.errors = error.errors;
    })
  }

}]);
