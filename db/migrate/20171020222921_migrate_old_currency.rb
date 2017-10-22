class MigrateOldCurrency < ActiveRecord::Migration
  def up
    ::Account::Template.update_all(currency: 'BTC')
  end

  def down
  end
end
