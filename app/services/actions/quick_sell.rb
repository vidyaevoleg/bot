module Actions
  class QuickSell
    attr_reader :summary,
      :wallet,
      :last_buy_order,
      :template

    def initialize(summary, template)
      @template = template
      @summary = summary
      @wallet = summary.wallet
      @last_buy_order = template.account.orders.where(market: summary.market, type: 'buy').last
    end

    def call
      if last_buy_order
        last_price = last_buy_order.price.to_f # цена последнего ордера на покупку
        min_difference = 1.to_f + (template.min_sell_percent_diff.to_f / 100.to_f)
        max_difference = 1.to_f + (template.min_sell_percent_stop.to_f / 100.to_f)
        if (last_buy_order.price.to_d / summary.ask.to_d) > max_difference.to_d
          to_black_list(summary.market)
          yield(summary, 'sell', order_volume, order_rate, Order.reasons[:stop_loss])
        else
          profit_rate = last_price * min_difference
          yield(summary, 'sell', order_volume, profit_rate, Order.reasons[:profit])
        end
      else
        to_black_list(summary.market)
        yield(summary, 'sell', order_volume, order_rate, Order.reasons[:too_long])
      end
    end

    private

    def to_black_list(market_name)
      new_black_list = template.black_list
      new_black_list << market_name
      template.update!(black_list: new_black_list.uniq)
      ::Accounts::UpdateBlackListWorker.perform_in(12.hours, template.id, market_name)
    end

    def order_volume
      wallet.available
    end

    def order_rate
      (summary.ask.to_d - ::Strategy::STH.to_d).to_f
    end
  end
end
