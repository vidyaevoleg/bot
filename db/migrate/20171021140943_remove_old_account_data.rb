class RemoveOldAccountData < ActiveRecord::Migration
  def up
    remove_column :account_sessions, :account_id
    remove_column :orders, :account_id
  end

  def down
    add_column :account_sessions, :account_id, :integer
    add_column :orders, :account_id, :integer
  end
end
