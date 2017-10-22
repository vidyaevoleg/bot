class AddStrategyToSessions < ActiveRecord::Migration
  def change
    add_column :account_sessions, :strategy, :string
  end
end
