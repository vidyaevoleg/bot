class AddLastTimeToAccountTemplates < ActiveRecord::Migration
  def change
    add_column :account_templates, :last_time, :datetime
  end
end
