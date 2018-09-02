class Account::Template < ActiveRecord::Base
  include WorkersHelper

  belongs_to :account
  has_many :orders, foreign_key: :account_template_id
  has_many :sessions, class_name: ::Account::Session, foreign_key: :account_template_id, dependent: :destroy
  has_many :reports, class_name: ::Account::Report, foreign_key: :account_template_id, dependent: :destroy
  has_many :wallets, class_name: ::Account::Wallet, foreign_key: :account_template_id, dependent: :destroy

  serialize :black_list, Array
  serialize :white_list, Array
  validates :currency, :account, :min_buy_price, presence: true

  enum strategy: {default: 0, only_sell: 1, deals_volume: 2}

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
      white_spread_percent_max: 6.0,
      white_spread_percent_min: 3.0,
      interval: 600
    }
  }

  def self.create_default(options = {})
    currency = (options[:currency] || 'BTC').to_sym
    create(DEFAULT[currency].merge(options).merge(currency: currency))
  end

  def run
    Runner.new(self).call
  end

  def coins_cache_key
    "#{currency}_coins_#{id}"
  end

  def off?
    !last_time || (Time.zone.now - last_time > interval)
  end

  def data
    fields = [DEFAULT.first[1].keys, :strategy, :currency].flatten
    fields.inject({}) do |_hash, field|
      _hash[field] = public_send(field)
      _hash
    end
  end

end
