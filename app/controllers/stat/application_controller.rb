module Stat
  class ApplicationController < ClientController

    before_action :prepare_orders

    def days
      render csv: Stat::DaysPresenter.to_csv(instances: @orders), filename: "All #{Time.zone.now.to_s}"
    end

    def all
      render csv: Stat::AllPresenter.to_csv(instances: @orders), filename: "All #{Time.zone.now.to_s}"
    end

    private

    def prepare_orders
      @orders = ::Order.where(created_at: DateTime.parse(params[:from])..DateTime.parse(params[:to]))
        .where("market like ?", "%#{params[:currency]}%")
        .where(account_template_id: current_user.template_ids)
    end
  end
end
