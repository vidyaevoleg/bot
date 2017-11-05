module Stat
  class DaysPresenter < BasePresenter
    attr_reader :orders, :day, :templates

    def initialize(day_with_orders)
      @day = day_with_orders.day
      @orders = day_with_orders.orders
      @templates = orders.map(&:template).uniq
    end

    def self.to_csv(options={})
      days = options[:instances].pluck(:closed_at).compact.map(&:to_date).uniq.sort
      days_objects = []
      days.each do |day|
        orders = options[:instances].where(closed_at: day.beginning_of_day..day.end_of_day)
        days_objects << Struct.new(:day, :orders).new(day, orders)
      end
      super(headers: false, instances: days_objects)
    end

    def spreadsheet_columns
      data = [
        ['Days', day],
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
        ['Average, sec', avarage]
      ]
      data
    end

    def method_missing(*args)
      'test'
    end

    def winrate
      ((profit_orders.count * 100) / (profit_orders.count + lesion_orders.count)).to_f.round(2)
    end

    def loserate
      ((lesion_orders.count * 100) / (profit_orders.count + lesion_orders.count)).to_f.round(2)
    end

    def turnover
      orders.find_all {|o| o.type == 'buy'}.map {|o| (o.quantity.to_f.to_d * o.price.to_f.to_d).to_f}.inject(&:+)
    end

    def turnover_from_deposite
      (turnover * 100 / deposit).to_f.round(2) if deposit
    end

    def deposit
      reports = Account::Report.where(account_template_id: templates.map(&:id))
        .where("created_at > ? AND created_at < ?", day.beginning_of_day, day.end_of_day).uniq {|r| r.account_template_id}
      reports.map {|r| r.balance.to_f}.inject(&:+) if reports.any?
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

    def avarage
      good_orders = orders.find_all {|o| o.created_at && o.closed_at}
      diffs = good_orders.map {|o| o.closed_at - o.created_at}.inject(&:+)
      diffs / good_orders.count if diffs
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
