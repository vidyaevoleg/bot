class AccountsController < ClientController

  def show
    account = Account.eager_load(templates: :wallets).find(params[:id])
    gon.account = AccountShowSerializer.new(account).as_json
    scope = Account::Session.where(account_template_id: account.templates.pluck(:id))
    sessions = [scope.last, scope.joins(:orders).includes(:template, :orders).order(id: :desc).limit(100)].flatten.uniq(&:id)
    gon.sessions = sessions.map {|s| SessionSerializer.new(s).as_json }
    gon.wallets = account.wallets.map {|w| WalletSerializer.new(w).as_json }
  end

end
