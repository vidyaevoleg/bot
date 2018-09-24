class Strategy
  attr_reader :summary, :template, :wallet, :balance, :currency, :account

  def initialize(summary, template, balance)
    @template = template
    @summary = summary
    @account = template.account
    @balance = balance
    @wallet = summary.wallet
    @currency = template.currency
  end

  def call
    if summary.wallet && summary.wallet.balance > 0
      try_to_sell { |*args| yield(*args) } unless Rails.env.development?
    else
      try_to_buy { |*args| yield(*args) }
    end
  end

  def try_to_sell
    if summary.wallet.balance * summary.bid < template.min_buy_price
      Actions::Buy.new(summary, template, :buy_more).call do |summary, type, price, volume, reason|
        yield(summary, type, price, volume, reason) if price * volume < balance
      end
    else
      reason = if order_not_found?
        :too_long
      elsif stop_loss?
        :stop_loss
      elsif grew_enough?
        :profit
      end
      if reason
        Actions::Sell.new(summary, template, reason).call do |*args|
          yield(*args)
        end
      end
    end
  end

  def try_to_buy
    if reason_to_buy?
      Actions::Buy.new(summary, template).call do |summary, type, price, volume, reason|
        # byebug
        yield(summary, type, price, volume, reason) if price * volume < balance
      end
    end
  end

  private

  def valid_spread?
    summary.spread > 0.01 && summary.spread < 0.20
  end

  def order_not_found?
    !last_buy_order
  end

  def min_trade_volume
    template.min_buy_price / summary.bid
  end

  def available_currency
    wallet.available_currency(currency)
  end

  def stop_loss?
    (last_buy_order.price.to_d / summary.ask.to_d) > (1.to_f + (template.min_sell_percent_diff.to_f / 100.to_f))
  end

  def grew_enough?
    last_price = last_buy_order.price
    ((summary.ask.to_d - STH.to_d) / last_price.to_d).to_f > 1.to_f + (template.min_sell_percent_stop.to_f / 100.to_f)
  end

  def last_buy_order
    @last_buy_order ||= account.orders.where(
      market: summary.market,
      type: 'buy',
      reason: Order.reasons[:future]).last
  end

  def market_active?
    summary.base_volume.to_f > template.min_market_volume.to_f
  end

  def valid_spread_percent?
    # проверяем спред в процентах
    summary.spread > (template.min_buy_percent_diff / 100) && summary.spread < (template.max_buy_percent_diff / 100)
  end

  def reason_to_buy?
    buy_conditions.each_with_index do |condition, index|
      unless condition
        puts "invalid condition #{index}".yellow
        return false
      end
    end
    true
  end
end
