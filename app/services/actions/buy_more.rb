module Actions
  class BuyMore
    attr_reader :summary,
      :wallet,
      :used_balance,
      :max_balance

    def initialize(summary, template, used_balance, max_balance)
      @summary = summary
      @wallet = summary.wallet
      @used_balance = used_balance
      @max_balance = max_balance
    end

    def call
      if condition
        yield(summary, 'buy', order_volume, order_rate, Order.reasons[:buy_more])
      end
    end

    private

    def condition
      used_balance + (order_rate * order_volume) < max_balance
    end

    def order_rate
      (summary.bid.to_d + ::Strategy::STH.to_d).to_f
    end

    def order_volume
      sum = template.min_buy_price
      (sum / order_rate.to_d).to_f
    end
  end
end
