class AddMaxBuyPercentToTemplates < ActiveRecord::Migration
  def change
    add_column :account_templates, :max_buy_percent_diff, :decimal, default: 4
  end
end
