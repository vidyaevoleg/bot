class Account::Template < ActiveRecord::Base
  belongs_to :account

  DEFAULT = {
    min_market_volume: 20,
    min_sell_percent_diff: 1,
    min_sell_percent_stop: 7,
    min_buy_sth_diff: 100,
    min_buy_percent_diff: 2,
    min_buy_price: 0.0006,
    interval: 180
  }

  def self.create_default(options = {})
    create(DEFAULT.merge(options))
  end


end
