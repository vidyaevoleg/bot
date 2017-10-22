class AddCurrencyIdToTemplate < ActiveRecord::Migration
  def change
    add_column :account_templates, :currency, :string
  end
end
