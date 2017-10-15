class IntergersToDecimal < ActiveRecord::Migration
  def up
    change_column :account_templates, :min_market_volume, :decimal
    change_column :account_templates, :min_sell_percent_diff, :decimal
    change_column :account_templates, :min_sell_percent_stop, :decimal
    change_column :account_templates, :min_buy_sth_diff, :decimal
    change_column :account_templates, :min_buy_percent_diff, :decimal
  end

  def down
    change_column :account_templates, :min_market_volume, :integer
    change_column :account_templates, :min_sell_percent_diff, :integer
    change_column :account_templates, :min_sell_percent_stop, :integer
    change_column :account_templates, :min_buy_sth_diff, :integer
    change_column :account_templates, :min_buy_percent_diff, :integer
  end
end
