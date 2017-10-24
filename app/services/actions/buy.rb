module Actions
  class Buy
    attr_reader :summary,
      :template,
      :used_balance,
      :max_balance

    def initialize(summary, template, used_balance, max_balance)
      @template = template
      @summary = summary
      @used_balance = used_balance
      @max_balance = max_balance
    end

    def call
      return if summary.base_volume.to_f < template.min_market_volume.to_f
      if condition1 && condition2 && condition3 && condition4 && condition5
        yield(summary, 'buy', order_volume, order_rate, Order.reasons[:future])
      end
    end

    private

    def condition1
      min_percent = template.min_buy_percent_diff.to_d / 100.to_d
      ((((summary.ask.to_d - ::Strategy::STH.to_d) - (summary.bid.to_d + ::Strategy::STH.to_d))) / (summary.bid.to_d + ::Strategy::STH.to_d)).to_f > min_percent
    end

    def condition2
      min_diff = template.min_buy_sth_diff.to_f * ::Strategy::STH.to_f
      ((summary.ask.to_d - ::Strategy::STH.to_d) - (summary.bid.to_d + ::Strategy::STH.to_d)).to_f > min_diff
    end

    def condition3
      !in_black_list?
    end

    def condition4
      used_balance + (order_rate * order_volume) < max_balance
    end

    def condition5
      last_sell_order = template.account.orders.where(market: summary.market, type: 'sell').last
      return true unless last_sell_order
      order = last_sell_order
      !(summary.spread.to_f > (template.min_pump_risk_percent.to_f / 100) && order.closed_at && order.closed_at > 24.hours.ago)
    end

    def in_black_list?
      template.black_list.include?(summary.market)
    end

    def order_rate
      (summary.bid.to_d + ::Strategy::STH.to_d).to_f
    end

    def in_white_list?
      template.white_list.include?(summary.market)
    end

    def order_volume
      default_volume = (template.min_buy_price.to_d / order_rate.to_d).to_f
      if in_white_list?
        default_volume * template.white_list_coef.to_f
      else
        default_volume
      end
    end
  end
end
