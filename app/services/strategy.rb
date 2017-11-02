class Strategy
  attr_reader :client,
    :account,
    :template,
    :wallets,
    :summaries,
    :orders,
    :session,
    :currency

  attr_accessor :used_balance

  STH = 0.00000001
  MIN_TRADE_VOLUME = 0.0005

  def initialize(template)
    @template = template
    sync_balances
    @account = template.account
    template.clear_workers
    @used_balance = 0.0
    @currency = template.currency
    @client = account.create_client
    close_orders
    @summaries = get_summaries
    save_coins
    @wallets = client.wallets.all
    keep_wallets
    sync_wallets
    puts 'DATA FETCHED'.yellow
    @session = template.sessions.create(buy_count: 0, sell_count: 0, payload: "", strategy: template.strategy)
  end

  def call
    perform_next_run
    summaries.each do |summary|
      fix(summary)
    end
    summaries.each do |summary|
      start(summary)
    end
    perform_check
    save_last_call
  end

  def fix(summary)
    wallet = summary.wallet
    if wallet && wallet.available_currency(currency) > 0 && wallet.available_currency(currency) < MIN_TRADE_VOLUME
      Actions::BuyMore.new(summary, template, used_balance, full_balance).call do |*args|
        new_order(*args)
      end
    end
  end

  def start(summary)
    return if our_currencies.include?(summary.market)
    wallet = summary.wallet
    if wallet && wallet.available_currency(currency) > MIN_TRADE_VOLUME
      Actions::Sell.new(summary, template).call do |*args|
        new_order(*args)
      end
    else
      Actions::Buy.new(summary, template, used_balance, full_balance).call do |*args|
        new_order(*args)
      end
    end
  end

  private

  def full_balance
    currency_wallet.available
  end

  def currency_wallet
    @_currency_wallet ||= wallets.find {|w| w.currency == currency}
  end

  def max_buy_deals_count
    (full_balance.to_d / template.min_buy_price.to_d).to_i
  end

  def new_order(summary, type, volume, price, reason = nil)
    sign = summary.market
    if type == 'buy'
      @used_balance = @used_balance.to_f + volume * price
    end
    puts "#{type} ордер  #{sign} по цене #{price} объемом #{volume} #{Time.zone.now} reason #{reason}".green
    puts "USED BALANCE #{used_balance}".green
    ::Orders::CreateWorker.perform_async(template.id, session.id, {
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

  def save_coins
    Rails.cache.write(template.coins_cache_key, summaries.map(&:market))
  end

  def get_summaries
    sums = client.summaries.all.find_all {|s| s.market.include?("#{currency}")}
    white_listed = sums.select {|s| template.white_list.include?(s.market)}
    by_spread = sums.sort {|s| s.spread }
    (white_listed + by_spread).uniq
  end

  def keep_wallets
    summaries.each do |summary|
      wallet = wallets.find { |w| w.sign(template.currency) == summary.market }
      summary.wallet = wallet
    end
  end

  def our_currencies
    return @_our_currencies if @_our_currencies
    words = template.account.templates.map {|t| "#{t.currency}"}
    @_our_currencies = []
    words.each do |word1|
      words.reverse.each do |word2|
        @_our_currencies << "#{word1}-#{word2}"
        @_our_currencies << "#{word2}-#{word1}"
      end
    end
    @_our_currencies.uniq
  end

  def save_last_call
    template.update!(last_time: Time.zone.now)
  end

  def perform_next_run
    StrategyWorker.perform_in(template.interval.seconds, template.id)
  end

  def sync_wallets
    Accounts::SyncWalletsWorker.perform_async(template.id)
  end

  def sync_balances
    Orders::SaveReportsWorker.perform_async(template.id)
  end

  def perform_check
    Accounts::SessionCheckWorker.perform_in(30.seconds, session.id)
  end

  def close_orders
    Orders::CloseOrders.run!(template: template)
  end
end
