module Actions
  class Buy < Base

    def call
      yield(summary, 'buy', price, volume, reason || :future)
    end

    private

    def volume
      (2 * template.min_buy_price.to_d / price).to_f
    end

    def price
      (summary.bid.to_d + STH.to_d).to_f
    end
  end
end
