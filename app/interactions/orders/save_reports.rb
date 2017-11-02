module Orders
  class SaveReports < ::ApplicationInteraction
    # attr_reader :orders, :account

    object :template, class: ::Account::Template

    def execute
      used_strategies.each do |strategy|
        orders = last_orders.joins(:session).where("account_sessions.strategy = ?", strategy).uniq
        next unless orders.any?
        next unless need_report?(strategy)
        last_order = orders.first
        next unless last_order.created_at > 1.days.ago
        ::Orders::SaveStrategyReport.run(strategy: strategy, template: template, orders: orders)
      end
    end

    private

    def need_report?(strategy)
      last_report = template.reports.last
      return true unless last_report
      last_report.created_at < 1.days.ago
    end

    def last_orders
      @_last_orders ||= template.orders.includes(:session).where("orders.created_at > ?", 1.days.ago).order(id: :desc)
    end

    def used_strategies
      @_used_strategies ||= last_orders.map(&:session).map(&:strategy).uniq
    end
  end
end
