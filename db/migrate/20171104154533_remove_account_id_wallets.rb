class RemoveAccountIdWallets < ActiveRecord::Migration
  def up
    remove_column :account_wallets, :account_id
  end

  def down
    add_column :account_wallets, :account_id, :integer
  end
end
