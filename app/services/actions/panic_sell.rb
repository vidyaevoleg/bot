module Actions
  class PanicSell
    attr_reader :summary, :template, :wallet

    def initialize(summary, wallet, template)
      @template = template
      @summary = summary
      @wallet = wallet
    end

    def call
      if condition1
        yield(summary, 'sell', order_volume, order_rate, Order.reasons[:panic_sell])
      end
    end

    private

    def condition1
      our_currencies = template.account.templates.map {|t| "BTC-#{t.currency}"}
      !our_currencies.include?(summary.market)
    end

    def order_volume
      wallet.available
    end

    def order_rate
      (summary.ask.to_d - ::Strategy::STH.to_d).to_f
    end
  end
end
