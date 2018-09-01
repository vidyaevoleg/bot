module Actions
  class Sell < Base
    attr_reader :wallet,
      :last_buy_order,
      :template

    def initialize(summary, template)
      super
      @summary = summary
      @wallet = summary.wallet
      @last_buy_order = template.account.orders.where(market: summary.market, type: 'buy').last
    end

    def call(&block)
      if last_buy_order
        last_price = last_buy_order.price # цена последнего ордера на покупку
        if price_grew_enough? # (ask + STH ) / last_price > на заданный процент
          yield(summary, 'sell', Order.reasons[:profit]) # ордер на продажу
        elsif (last_buy_order.price.to_d / summary.ask.to_d) > max_difference.to_d # цена уменьшилась на этот процент
          yield(summary, 'sell', Order.reasons[:stop_loss]) #ордер на продажу
        end
      else
        yield(summary, 'sell',  Order.reasons[:too_long]) #ордер на продажу
      end
    end

    private

    def price_grew_enough?
      ((summary.ask.to_d - STH.to_d) / last_price.to_d).to_f > min_difference
    end

    def max_difference
      1.to_f + (template.min_sell_percent_diff.to_f / 100.to_f)
    end

    def min_difference
      1.to_f + (template.min_sell_percent_stop.to_f / 100.to_f)
    end

    def order_volume
      wallet.available
    end

    def order_rate
      (summary.ask.to_d - STH.to_d).to_f
    end
  end
end
