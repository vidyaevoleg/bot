class AddStrategyToTemplates < ActiveRecord::Migration
  def change
    add_column :account_templates, :strategy, :integer, default: 0
  end
end
