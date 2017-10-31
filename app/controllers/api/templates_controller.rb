module Api
  class TemplatesController < ::Api::ApplicationController

    def create
      template = ::Account::Template.create!(create_params)
      respond_with template, serializer: AccountTemplateSerializer, location: nil
    end

    def update
      template.update!(update_params)
      respond_with template, serializer: AccountTemplateSerializer, location: nil
    end

    def start
      template.run_strategy
      render json: :ok
    end

    def off
      template.update(last_time: nil)
      Orders::CloseOrders.run!(template: template)
      template.clear_workers
      render json: :ok
    end

    def destroy
      template.destroy
      render nothing: true
    end

    private

    def create_params
      template_params.merge(account: account)
    end

    def update_params
      template_params
    end

    def account
      @_account ||= current_user.accounts.find(params[:template][:account_id]) rescue nil
    end

    def template
      @_template ||= current_user.templates.find(params[:id])
    end

    def template_params
      params.require(:template).permit(
        :min_market_volume,
        :min_sell_percent_diff,
        :min_sell_percent_stop,
        :min_buy_percent_diff,
        :max_buy_percent_diff,
        :min_buy_sth_diff,
        :min_buy_price,
        :min_pump_risk_percent,
        :interval,
        :white_list_coef,
        :currency,
        :strategy,
        :account_id,
        black_list: [],
        white_list: []
      )
    end


  end
end
