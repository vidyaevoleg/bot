module Api
  class ApplicationController < ::ClientController
    exclude_xsrf_token_cookie
    self.responder = ApplicationResponder
    respond_to :json
  end
end
