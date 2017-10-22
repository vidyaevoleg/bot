module Actions
  class PanicSell
    attr_reader :summary, :template, :wallet

    def initialize(summary, template)
      @template = template
      @summary = summary
      @wallet = summary.wallet
    end

    def call
      yield(summary, 'sell', order_volume, order_rate, Order.reasons[:panic_sell])
    end

    private

    def order_volume
      wallet.available
    end

    def order_rate
      (summary.ask.to_d - ::Strategy::STH.to_d).to_f
    end
  end
end
