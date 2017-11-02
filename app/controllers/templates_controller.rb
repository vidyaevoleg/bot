class TemplatesController < ClientController

  def show
    template = ::Account::Template.includes(:reports).find(params[:id])
    gon.template = AccountTemplateShowSerializer.new(template).as_json
  end

end
