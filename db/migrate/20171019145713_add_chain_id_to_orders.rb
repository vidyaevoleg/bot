class AddChainIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :chain_id, :string
  end
end
