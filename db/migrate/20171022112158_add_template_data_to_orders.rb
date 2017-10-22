class AddTemplateDataToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :template_data, :text
  end
end
