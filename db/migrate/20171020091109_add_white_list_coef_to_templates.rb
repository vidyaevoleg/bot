class AddWhiteListCoefToTemplates < ActiveRecord::Migration
  def change
    add_column :account_templates, :white_list_coef, :decimal, default: Account::Template::DEFAULT[:white_list_coef]
  end
end
