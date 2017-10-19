class Strategy::Buy
  attr_reader :summary,
    :account,
    :settings,
    :orders

  def initialize(summary, account, orders)
    @account = account
    @settings = account.template
    @summary = summary
    @orders = orders
  end

  def call
    return if summary.base_volume.to_f < settings.min_market_volume.to_f
    if condition1 && condition2 && condition3 && condition4
      yield(summary, 'buy', order_volume, order_rate, Order.reasons[:future])
    end
  end

  private

  def condition1
    min_percent = settings.min_buy_percent_diff.to_d / 100.to_d
    ((((summary.ask.to_d - ::Strategy::STH.to_d) - (summary.bid.to_d + ::Strategy::STH.to_d))) / (summary.bid.to_d + ::Strategy::STH.to_d)).to_f > min_percent
  end

  def condition2
    min_diff = settings.min_buy_sth_diff.to_f * ::Strategy::STH.to_f
    ((summary.ask.to_d - ::Strategy::STH.to_d) - (summary.bid.to_d + ::Strategy::STH.to_d)).to_f > min_diff
  end

  def condition3
    !in_black_list?(summary.market)
  end

  def condition4
    last_sell_order = orders.find do |order|
      order.market == summary.market && order.sell?
    end
    return true unless last_sell_order
    order = last_sell_order
    !(summary.spread.to_f > (settings.min_pump_risk_percent.to_f / 100) && order.closed_at && order.closed_at > 24.hours.ago)
  end

  def in_black_list?(market_name)
    settings.black_list.include?(market_name)
  end

  def order_rate
    (summary.bid.to_d + ::Strategy::STH.to_d).to_f
  end

  def order_volume
    (settings.min_buy_price.to_d / order_rate.to_d).to_f
  end
end
