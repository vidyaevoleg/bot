module Stat
  class ApplicationController < ClientController

    before_action :prepare_orders

    def days
      render csv: Stat::DaysPresenter.to_csv(instances: @orders), filename: "Days #{Time.zone.now.to_s}"
    end

    def all
      render csv: Stat::AllPresenter.to_csv(instances: @orders), filename: "All #{Time.zone.now.to_s}"
    end

    def markets
      render csv: Stat::MarketsPresenter.to_csv(instances: @orders), filename: "Markets #{Time.zone.now.to_s}"
    end

    def spreads
      render csv: Stat::SpreadsPresenter.to_csv(instances: @orders), filename: "Spreads #{Time.zone.now.to_s}"
    end

    def volumes
      render csv: Stat::VolumesPresenter.to_csv(instances: @orders, currency: params[:currency]), filename: "Volumes #{Time.zone.now.to_s}"
    end

    def configs
      orders = @orders.map do |o|
        o.template_data.each do |k,v|
          o.define_singleton_method(k) {v}
        end
        o
      end
      render csv: Stat::ConfigsPresenter.to_csv(instances: orders, config: params[:config]), filename: "#{params[:config]} #{Time.zone.now.to_s}"
    end

    def times
      render csv: Stat::TimesPresenter.to_csv(instances: @orders), filename: "Times #{Time.zone.now.to_s}"
    end

    private

    def prepare_orders
      @orders = ::Order.includes(:template).where(created_at: DateTime.parse(params[:from])..DateTime.parse(params[:to]))
        .where("market like ?", "%#{params[:currency]}%")
        .where(account_template_id: current_user.template_ids)
    end
  end
end
