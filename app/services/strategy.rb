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
    if summary.wallet
      try_to_sell { |*args| yield(*args) }
    else
      try_to_buy { |*args| yield(*args) }
    end
  end

  def try_to_sell
    if available_currency > 0 && (available_currency < min_trade_volume) && valid_spread?
      Actions::Buy.new(summary, template, :buy_more).call do |summary, type, price, volume, reason|
        yield(summary, type, price, volume, reason) if price * volume < balance
      end
    elsif available_currency >= min_trade_volume
      reason = if order_not_found?
        :too_long
      elsif stop_loss?
        :stop_loss
      end
      Actions::Sell.new(summary, template, reason).call do |*args|
        yield(*args)
      end
    end
  end

  def try_to_buy
    if reason_to_buy?
      Actions::Buy.new(summary, template).call do |summary, type, price, volume, reason|
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
    summary.bid * template.min_buy_price
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
      type: 'buy').last
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
