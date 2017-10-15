class AddProfitToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :reason, :integer
    add_column :orders, :profit, :decimal
  end
end
