class Account::Template < ActiveRecord::Base
  include WorkersHelper

  belongs_to :account
  has_many :orders, foreign_key: :account_template_id
  has_many :sessions, class_name: Account::Session, foreign_key: :account_template_id

  serialize :black_list, Array
  serialize :white_list, Array
  validates :currency, :account, :min_buy_price,  presence: true

  enum strategy: {default: 0, sell: 1, quick_sell: 2, rank_volume: 3}

  DEFAULT = {
    ETH: {
      min_market_volume: 20,
      min_sell_percent_diff: 1,
      min_sell_percent_stop: 7,
      min_buy_sth_diff: 100,
      min_buy_percent_diff: 2,
      min_buy_price: 0.0006,
      white_list_coef: 2.0,
      interval: 600
    },
    BTC: {
      min_market_volume: 20,
      min_sell_percent_diff: 1,
      min_sell_percent_stop: 7,
      min_buy_sth_diff: 100,
      min_buy_percent_diff: 2,
      max_buy_percent_diff: 4,
      min_buy_price: 0.0006,
      white_list_coef: 2.0,
      interval: 600
    }
  }

  def self.create_default(options = {})
    currency = (options[:currency] || 'BTC').to_sym
    create(DEFAULT[currency].merge(options).merge(currency: currency))
  end

  def run_strategy
    strategy_klass = strategy.classify
    Strategy.const_get(strategy_klass).new(self).call
  end

  def coins_cache_key
    "#{currency}_coins"
  end

  def data
    fields = [DEFAULT.first[1].keys, :strategy, :currency].flatten
    fields.inject({}) do |_hash, field|
      _hash[field] = public_send(field)
      _hash
    end
  end

end
