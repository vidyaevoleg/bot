APP.service('API', ['$http', function ($http) {

  return {
    accounts: {
      path: '/api/accounts',
      createOrUpdate: function (account) {
        if (account.id) {
          return $http.put(this.path + '/' + account.id, account);
        } else {
          return $http.post(this.path + '/', account);
        }
      },
      getSessions: function (id) {
        return $http.get(this.path + '/' + id + "/sessions");
      },
      delete: function (id) {
        return $http.delete(this.path + '/' + id);
      }
    },
    templates: {
      path: '/api/templates',
      createOrUpdate: function (template) {
        if (template.id) {
          return $http.put(this.path + '/' + template.id, template);
        } else {
          return $http.post(this.path + '/', template);
        }
      },
      delete: function (id) {
        return $http.delete(this.path + '/' + id);
      },
      start: function (id) {
        return $http.post(this.path + '/' + id + "/start");
      },
      off: function (id) {
        return $http.post(this.path + '/' + id + "/off");
      }
    }
  }

}]);
