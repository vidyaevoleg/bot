module Actions
  class QuickSell < Sell
    attr_reader :summary,
      :wallet,
      :last_buy_order,
      :template

    def initialize(summary, template)
      super
      @wallet = summary.wallet
      @last_buy_order = template.account.orders.where(market: summary.market, type: 'buy').last
    end

    def call
      if last_buy_order
        last_price = last_buy_order.price.to_f # цена последнего ордера на покупку
        if price_down_to_much?
          yield(summary, 'sell', order_volume, order_rate, Order.reasons[:stop_loss])
        else
          profit_rate = last_price * min_difference
          yield(summary, 'sell', order_volume, profit_rate, Order.reasons[:profit])
        end
      else
        yield(summary, 'sell', order_volume, order_rate, Order.reasons[:too_long])
      end
    end

    private

    def price_down_to_much?
      (last_buy_order.price.to_d / summary.ask.to_d) > max_difference.to_d
    end

  end
end
