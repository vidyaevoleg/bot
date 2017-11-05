class AccountsController < ClientController

  def show
    account = Account.eager_load(templates: :wallets).find(params[:id])
    gon.account = AccountShowSerializer.new(account).as_json
    sessions = Account::Session.includes(:template, :orders).where(account_template_id: account.templates.pluck(:id)).order(id: :desc).limit(100)
    gon.sessions = sessions.map {|s| SessionSerializer.new(s).as_json }
    gon.wallets = account.wallets.map {|w| WalletSerializer.new(w).as_json }

  end

end
