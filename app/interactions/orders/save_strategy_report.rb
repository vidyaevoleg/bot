module Orders
  class SaveStrategyReport < ::ApplicationInteraction
    attr_reader :account

    string :strategy
    object :template,  class: ::Account::Template
    array :orders, default: []

    def execute
      @account = template.account
      template.reports.create(
        balance: balance,
        strategy: strategy,
        profit: profit,
        currency: template.currency,
        payload: payload,
      )
    end

    private

    def balance
      account.wallets.map do |w|
        if w.currency == 'BTC'
          w.available.to_f
        else
          w.available_btc.to_f
        end
      end.inject(&:+)
    end

    def profit
      orders.map {|o| o.profit.to_f}.inject(&:+)
    end

    def payload
      {}
    end

  end
end
