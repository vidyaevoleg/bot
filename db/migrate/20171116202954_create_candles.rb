class CreateCandles < ActiveRecord::Migration
  def change
    create_table :candles do |t|
      t.decimal :min
      t.decimal :max
      t.integer :provider
      t.string :market
      t.decimal :ask
      t.decimal :bid
      t.timestamps
    end
  end
end
