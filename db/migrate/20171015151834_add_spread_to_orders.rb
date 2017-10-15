class AddSpreadToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :spread, :decimal
    add_column :orders, :volume, :decimal
  end
end
