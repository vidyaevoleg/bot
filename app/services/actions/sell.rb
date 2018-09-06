module Actions
  class Sell < Base

    def call
      yield(summary, 'sell', price, volume, reason || :profit)
    end

    private

    def volume
      summary.wallet.available
    end

    def price
      (summary.ask.to_d - STH.to_d).to_f
    end
  end
end
