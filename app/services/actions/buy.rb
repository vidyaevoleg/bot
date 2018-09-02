module Actions
  class Buy < Base
    attr_reader :market, :provider

    def call
      yield(summary, 'buy', price, volume, Order.reasons[:future])
    end

    private

    def volume
      (template.min_buy_price.to_d / summary.rate.to_d).to_f
    end

    def price
      (summary.ask.to_d + STH.to_d).to_f
    end
  end
end
