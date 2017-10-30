class CreateWallets < ActiveRecord::Migration
  def change
    create_table :account_wallets do |t|
      t.string :currency
      t.decimal :available
      t.decimal :available_btc
      t.references :account, index: true
    end
  end
end
