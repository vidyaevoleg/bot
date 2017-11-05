class AddWhiteSpreadHigh < ActiveRecord::Migration
  def change
    add_column :account_templates, :white_spread_percent_min, :decimal, default: 4.0
    add_column :account_templates, :white_spread_percent_max, :decimal, default: 6.0
  end
end
