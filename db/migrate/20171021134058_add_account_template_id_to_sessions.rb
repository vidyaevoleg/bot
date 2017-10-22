class AddAccountTemplateIdToSessions < ActiveRecord::Migration
  def change
    add_column :account_sessions, :account_template_id, :integer, index: true
    add_column :orders, :account_template_id, :integer, index: true 
  end
end
