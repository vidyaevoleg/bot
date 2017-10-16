class AddSellCountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :sell_count, :integer
    add_column :orders, :buy_count, :integer
    add_column :orders, :yesterday_price, :decimal
  end
end
