class AddWhiteListToAccountTemplates < ActiveRecord::Migration
  def change
    add_column :account_templates, :black_list, :text
    add_column :account_templates, :white_list, :text
  end
end
