module Actions
  class BuyMore < Base

    def call
      yield(summary, 'buy', price, volume, Order.reasons[:buy_more])
    end

    private

    def volume
      min_trade_volume
    end

    def price
      (summary.bid.to_d + STH.to_d).to_f
    end

    def min_trade_volume
      summary.bid * template.min_buy_price
    end
  end
end
