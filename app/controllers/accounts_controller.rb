class AccountsController < ClientController

  def show
    account = Account.eager_load(:templates).find(params[:id])
    sessions = Account::Session.includes(:template, :orders).where(account_template_id: account.templates.pluck(:id)).order(id: :desc).limit(100)
    gon.account = AccountSerializer.new(account).as_json
    gon.sessions = sessions.map {|s| SessionSerializer.new(s).as_json}
  end

end
