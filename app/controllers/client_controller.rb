class ClientController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def main
    @accounts = Account.where(user: current_user)
  end

  def set_user
    if current_user
      user_data = User.includes(:accounts).find(current_user.id)
      user_data = UserSerializer.new(user_data).as_json
      gon.current_user = user_data
    end
  end


end
