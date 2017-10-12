APP.service('modalService', ['$uibModal', function ($uibModal){

  var currentModal;
  var currentScope;

  function get () {
    return currentModal;
  }

  function init (template, controller, scope, size ) {
    var settings = {
      animation: true,
      templateUrl: template,
      controller: controller
    };
    if (size) settings.size = size;
    currentScope = scope;
    currentModal = $uibModal.open(settings)
  }

  function close () {
    currentModal.dismiss('cancel');
  }

  function getScope() {
    return currentScope;
  }

  return {
    init: init,
    getScope: getScope,
    get: get,
    close : close
  };

}]);
