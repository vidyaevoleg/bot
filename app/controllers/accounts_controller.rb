class AccountsController < ClientController

  def show
    account = Account.eager_load(:templates).find(params[:id])
    sessions = Account::Session.includes(:template).where(account_template_id: account.templates.pluck(:id)).reverse
    gon.account = AccountSerializer.new(account).as_json
    gon.sessions = sessions.map {|s| SessionSerializer.new(s).as_json}
  end

end
