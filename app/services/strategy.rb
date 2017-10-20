require 'colorize'
# Sidekiq::Extensions.enable_delay!
class Strategy
  attr_reader :client,
    :account,
    :wallets,
    :summaries,
    :orders,
    :settings,
    :session

  attr_accessor :used_balance

  STH = 0.00000001
  MIN_TRADE_VOLUME = 0.0005

  def initialize(account)
    account.clear_workers
    @used_balance = 0.0
    @settings = account.template
    @account = account
    @client = account.create_client
    close_orders
    @summaries = get_summaries
    save_coins
    @wallets = client.wallets.all
    @orders = client.orders.all
    keep_wallets
    puts 'DATA FETCHED'.yellow
    @session = account.sessions.create(buy_count: 0, sell_count: 0, payload: "")
  end

  def call
    summaries.each do |summary|
      fix(summary)
    end
    summaries.each do |summary|
      start(summary)
    end
    perform_next_run
  end

  def fix(summary)
    wallet = summary.wallet
    if wallet && wallet.available_btc > 0 && wallet.available_btc < MIN_TRADE_VOLUME
      if session.buy_count <= max_buy_deals_count
        Strategy::BuyMore.new(summary, account).call do |*args|
          new_order(*args)
        end
      end
    end
  end

  def start(summary)
    wallet = summary.wallet
    if wallet && wallet.available_btc > MIN_TRADE_VOLUME
      Strategy::Sell.new(summary, account, orders).call do |*args|
        new_order(*args)
      end
    else
      Strategy::Buy.new(summary, account, orders, used_balance, full_balance).call do |*args|
        new_order(*args)
      end
    end
  end

  private

  def full_balance
    btc_wallet.available
  end

  def btc_wallet
    @_btc_wallet ||= wallets.find {|w| w.currency == 'BTC'}
  end

  def max_buy_deals_count
    (full_balance.to_d / settings.min_buy_price.to_d).to_i
  end

  def new_order(summary, type, volume, price, reason = nil)
    sign = summary.market
    if type == 'buy'
      @used_balance = @used_balance.to_f + volume * price
    end
    puts "#{type} ордер  #{sign} по цене #{price} объемом #{volume} #{Time.zone.now} reason #{reason}".green
    puts "USED BALANCE #{used_balance}".green
    ::Orders::CreateWorker.perform_async(account.id, session.id, {
      sign: sign,
      type: type,
      volume: volume,
      price: price,
    }, {
      reason: reason,
      volume: summary.base_volume,
      spread: summary.spread,
      sell_count: summary.sell_count,
      buy_count: summary.buy_count,
      yesterday_price: summary.yesterday_price
    })
  end

  private

  def save_coins
    Rails.cache.write(account.coins_cache_key, summaries.map(&:market))
  end

  def get_summaries
    sums = client.summaries.btc
    white_listed = sums.select {|s| settings.white_list.include?(s.market)}
    by_spread = sums.sort {|s| s.spread }
    (white_listed + by_spread).uniq
  end

  def keep_wallets
    summaries.each do |summary|
      wallet = wallets.find { |w| w.sign == summary.market }
      summary.wallet = wallet
    end
  end

  def perform_next_run
    StrategyWorker.perform_in(settings.interval.seconds, account.id)
  end

  def close_orders
    Orders::CloseOrders.run!(account: account)
  end
end
