class AddMinPumpRiskPercentToAccountTemplates < ActiveRecord::Migration
  def change
    add_column :account_templates, :min_pump_risk_percent, :decimal, default: 5.0
    add_column :orders, :closed_at, :datetime
  end
end
