class ClientController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:main]

  def main
    @accounts = Account.where(user: current_user)
  end

  def download
    @orders = Order.includes(:template).where(account_template_id: current_user.templates.pluck(:id))
    render csv: @orders.to_csv, filename: "Orders #{Time.zone.now.to_s}"
  end

  private

  def set_user
    if current_user
      user_data = User.includes(:accounts).find(current_user.id)
      user_data = UserSerializer.new(user_data).as_json
      gon.current_user = user_data
    end
  end

end
