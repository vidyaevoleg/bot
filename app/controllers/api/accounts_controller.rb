module Api
  class AccountsController < ::Api::ApplicationController

    def create
      result = Accounts::Create.run(create_params.merge(user: current_user))
      respond_with result, serializer: AccountSerializer, location: nil
    end

    def update
      account = current_user.accounts.find(params[:id])
      account.update(update_params)
      respond_with account, serializer: AccountSerializer, location: nil
    end

    def sessions
      account = current_user.accounts.find(params[:id])
      sessions = Account.eager_load(templates: [:orders, :sessions]).find(params[:id]).sessions.order(id: :desc).limit(100)
      respond_with sessions, each_serializer: SessionSerializer, root: :sessions
    end

    def destroy
      account = current_user.accounts.find(params[:id])
      account.destroy
      render nothing: true
    end

    private

    def create_params
      params.require(:account).permit(:key, :secret, :provider)
    end

    def update_params
      create_params
    end

  end
end
