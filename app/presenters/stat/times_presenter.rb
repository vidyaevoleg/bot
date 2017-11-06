module Stat
  class TimesPresenter < BasePresenter
    attr_reader :orders, :time, :template

    def initialize(time_with_orders)
      @time = time_with_orders.time
      @orders = time_with_orders.orders
      @template = orders.first.template
    end

    def self.to_csv(options={})
      times = options[:instances].pluck(:closed_at).compact.map(&:to_date).uniq.sort
      times_objects = []
      steps = [0, 300, 600, 1200, 1800, 3600, 4800, 7200, 9000, 10800, 14400, 18000, 25200, 32400, 43200, 54000, 64800, 86400]
      steps.each_with_index do |step, i|
        next_step = steps[i+1]
        if next_step
          orders = options[:instances].where.not(closed_at: nil)
            .find_all {|o|
              (o.closed_at - o.created_at).abs > step && (o.closed_at - o.created_at).abs < next_step
            }
          times_objects << Struct.new(:time, :orders).new(step, orders) if orders.any?
        end
      end
      super(headers: false, instances: times_objects)
    end

    def spreadsheet_columns
      data = [
        ['Time, min', (time / 60)],
        ['Deals', orders.count],
        ['Winrate, %', winrate],
        ['Loserate, %', loserate],
        ['Turnover', turnover],
        ['Turnover from Deposite, %', turnover_from_deposite],
        ['Profit', profit],
        ['ROI', roi],
        ['Profit With Deposit, %', profit_from_deposit],
        ['Median win ROI', median_win_roi],
        ['Median loss ROI', median_loss_roi],
      ]
      data
    end

    def method_missing(*args)
      'test'
    end

    def winrate
      if profit_orders.count + lesion_orders.count > 0
        ((profit_orders.count * 100) / (profit_orders.count + lesion_orders.count)).to_f.round(2)
      end
    end

    def loserate
      if profit_orders.count + lesion_orders.count > 0
        ((lesion_orders.count * 100) / (profit_orders.count + lesion_orders.count)).to_f.round(2)
      end
    end

    def turnover
      orders.find_all {|o| o.type == 'buy'}.map {|o| (o.quantity.to_f.to_d * o.price.to_f.to_d).to_f}.inject(&:+)
    end

    def turnover_from_deposite
      (turnover * 100 / deposit).to_f.round(2) if turnover && deposit
    end

    def deposit
      first_report =  Account::Report.where(account_template_id: template.id).first
      first_report.balance if first_report
    end

    def roi
      profit.to_f / turnover.to_f
    end

    def profit
      orders.map(&:profit).compact.map(&:to_f).inject(&:+).to_f
    end

    def profit_from_deposit
      (profit * 100 / deposit).to_f.round(2) if deposit
    end

    def median_win_roi
      median(profit_orders.map(&:profit).compact).to_f.round(8)
    end

    def median_loss_roi
      median(lesion_orders.map(&:profit).compact).to_f.round(8)
    end

    def median(array)
      return if array.empty?
      sorted = array.sort
      len = sorted.length
      (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end

    def profit_orders
      orders.find_all {|o| o.type == 'sell' && o.profit.to_f > 0}
    end

    def lesion_orders
      orders.find_all {|o| o.type == 'sell' && o.profit.to_f < 0}
    end
  end
end
