class TemplatesController < ClientController

  def show
    template = ::Account::Template.includes(:reports, :wallets).find(params[:id])
    gon.template = AccountTemplateShowSerializer.new(template).as_json
    sessions = Account::Session.includes(:template, :orders).where(account_template_id: template.id).order(id: :desc).limit(100)
    gon.sessions = sessions.map {|s| SessionSerializer.new(s).as_json }
  end

end
