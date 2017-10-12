module Api
  class AccountsController < ::Api::ApplicationController

    def create
      result = Accounts::Create.run(create_params.merge(user: current_user))
      respond_with result, serializer: AccountSerializer, location: nil
    end

    def update
      account = current_user.accounts.find(params[:id])
      result = Accounts::UpdateTemplate.run(update_params.merge(account: account))
      respond_with result, serializer: AccountSerializer, location: nil
    end

    def sessions
      account = current_user.accounts.find(params[:id])
      sessions = Account::Session.eager_load(:orders).where(account: account).order(id: :desc).limit(100)
      respond_with sessions, each_serializer: SessionSerializer, root: :sessions
    end

    def start
      account = current_user.accounts.find(params[:id])
      Strategy.new(account).call
      render json: :ok
    end

    def destroy
      account = current_user.accounts.find(params[:id])
      render nothing: true
    end

    private

    def create_params
      params.require(:account).permit(:key, :secret, :provider)
    end

    def update_params
      params.require(:template).permit(
        :min_market_volume,
        :min_sell_percent_diff,
        :min_sell_percent_stop,
        :min_buy_percent_diff,
        :min_buy_sth_diff,
        :min_buy_price,
        :interval
      )
    end


  end
end
