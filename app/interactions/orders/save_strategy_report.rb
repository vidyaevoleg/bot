module Orders
  class SaveStrategyReport < ::ApplicationInteraction

    string :strategy
    object :template,  class: ::Account::Template
    array :orders, default: []

    def execute
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
      template.wallets.map do |w|
        w.available_currency.to_f
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
