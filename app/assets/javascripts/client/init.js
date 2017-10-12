var APP = angular.module('robot', [
  'templates',
  'ui.bootstrap',
  'ngTouch',
  'angular-carousel',
  'angularUtils.directives.dirPagination',
  'ui-notification'
]);

APP.config(['NotificationProvider', function(NotificationProvider) {
  NotificationProvider.setOptions({
    delay: 5000,
    startTop: 20,
    startRight: 10,
    verticalSpacing: 20,
    horizontalSpacing: 20,
    positionX: 'right',
    positionY: 'top'
  });
}]);
