class AddReferencesToWallets < ActiveRecord::Migration
  def change
    add_column :account_wallets, :account_template_id, :integer, index: true
  end
end
