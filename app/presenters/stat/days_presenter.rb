module Stat
  class DaysPresenter < BasePresenter
    attr_reader :orders, :day

    def initialize(day_with_orders)
      @day = day_with_orders.day
      @orders = day_with_orders.orders
    end

    def self.to_csv(options={})
      days = options[:instances].pluck(:closed_at).compact.map(&:to_date).uniq.sort
      days_objects = []
      days.each do |day|
        orders = options[:instances].where(closed_at: day..(day + 1.days))
        days_objects << Struct.new(:day, :orders).new(day, orders)
      end
      super(headers: false, instances: days_objects)
    end

    # Days. Выгрузка по дням (отдельно по ETH и по BTC). Какие данные должны считаться по каждому дню (плюс, строка total, в которой высчитываются все нижеперечисленные данные за все дни, за которые строится отчет):
    # Deals. Количество цепочек сделок за этот день.
    # Winrate. Количество профитных цепочек (profit>0)/Количество цепочек сделок (buy-sell) за этот день
    # Turnover. Сумма вложенных средств в этот день. Сумма всех объемов (для BTC отчета в BTC, для ETH отчета в ETH) buy ордеров цепочек за этот день.
    # Turnover from Deposite. Turnover/Deposite, где Deposite = Estimated Value: in BTC с биржи.
    # Profit. Сумма профита всех цепочек сделок в этот день. Для BTC отчета в BTC, для ETH отчета в ETH.
    # ROI. Profit/Turnover
    # Profit from Deposite. Profit/Deposite
    # Median win ROI. Медиана от значений ROI каждой сделки, профит которой выше 0, за этот день
    # Median loss ROI. Медиана от значений ROI каждой сделки, профит которой ниже 0, за этот день
    # Average time from buy to sell. Среднее по разницам между Closed date продажи и closed date покупки внутри каждой цепочки сделки за этот день

    def spreadsheet_columns
      data = [
        ['Days', day],
        ['Deals', orders.count],
        ['Winrate', winrate],
        ['Turnover', turnover],
        ['Turnover from Deposite', turnover_from_deposite],
        ['Profit', profit],
        ['ROI', roi],
        ['Profit With Deposit', profit_from_deposit],
        ['Median win ROI', median_win_roi],
        ['Median loss ROI', median_loss_roi],
        ['Average', avarage]
      ]
      data
    end

    def method_missing(*args)
      'test'
    end

    def winrate
      profit_orders.count
    end

    def turnover
      orders.find_all {|o| o.type == 'buy'}.map {|o| (o.quantity.to_f.to_d * o.price.to_f.to_d).to_f}.inject(&:+)
    end

    def turnover_from_deposite
      nil
    end

    def roi
      profit.to_f / turnover.to_f
    end

    def profit
      orders.map(&:profit).compact.map(&:to_f).inject(&:+).to_f
    end

    def profit_orders
      orders.find_all {|o| o.type == 'sell' && o.profit.to_f > 0}
    end
  end
end
