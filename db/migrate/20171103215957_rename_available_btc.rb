class RenameAvailableBtc < ActiveRecord::Migration
  def up
    rename_column :account_wallets, :available_btc, :available_currency
  end

  def down
    rename_column :account_wallets, :available_currency, :available_btc
  end
end
