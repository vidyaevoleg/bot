class Strategy::Sell
  attr_reader :summary,
    :wallet,
    :last_buy_order,
    :account,
    :settings

  def initialize(summary, account, orders)
    @account = account
    @settings = account.template
    @summary = summary
    @wallet = summary.wallet
    @last_buy_order = orders.find do |order|
      order.market == wallet.sign && order.buy?
    end
  end

  def call
    if last_buy_order
      last_price = last_buy_order.price # цена последнего ордера на покупку
      min_difference = 1.to_f + (settings.min_sell_percent_diff.to_f / 100.to_f)
      max_difference = 1.to_f + (settings.min_sell_percent_stop.to_f / 100.to_f)

      if ((summary.ask.to_d - ::Strategy::STH.to_d) / last_price.to_d).to_f > min_difference # (ask + STH ) / last_price > на заданный процент
        yield(summary, 'sell', order_volume, order_rate, Order.reasons[:profit]) # ордер на продажу
      elsif (last_buy_order.price.to_d / summary.ask.to_d) > max_difference.to_d # цена уменьшилась на этот процент
        yield(summary, 'sell', order_volume, order_rate, Order.reasons[:stop_loss]) #ордер на продажу
      end
    else
      yield(summary, 'sell', order_volume, order_rate, Order.reasons[:too_long]) #ордер на продажу
    end
  end

  private

  def order_volume
    wallet.available
  end

  def order_rate
    (summary.ask.to_d - ::Strategy::STH.to_d).to_f
  end
end
