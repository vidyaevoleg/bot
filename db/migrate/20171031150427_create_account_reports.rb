class CreateAccountReports < ActiveRecord::Migration
  def change
    create_table :account_reports do |t|
      t.integer :account_template_id, index: true
      t.integer :type, default: 0
      t.decimal :balance, default: 0
      t.decimal :profit, default: 0
      t.string :currency
      t.string :strategy
      t.date :datetime
      t.text :payload
      t.timestamps
    end
  end
end
