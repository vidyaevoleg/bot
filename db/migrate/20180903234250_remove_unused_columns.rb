class RemoveUnusedColumns < ActiveRecord::Migration
  def up
    remove_column :account_templates, :min_pump_risk_percent
    remove_column :account_templates, :white_spread_percent_min
    remove_column :account_templates, :white_spread_percent_max
    remove_column :account_templates, :white_list
    remove_column :account_templates, :black_list
    remove_column :account_templates, :white_list_coef
  end

  def down
    add_column :account_templates, :min_pump_risk_percent, :integer
    add_column :account_templates, :white_spread_percent_min, :integer
    add_column :account_templates, :white_spread_percent_max, :integer
    add_column :account_templates, :white_list, :text
    add_column :account_templates, :black_list, :text
    add_column :account_templates, :white_list_coef, :integer
  end
end
