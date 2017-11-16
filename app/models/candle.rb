class Candle < ActiveRecord::Base
  enum provider: {bittrex: 0, poloniex: 1}
  validates :min, :max, :ask, :bid, :provider, :market, presence: true
end
