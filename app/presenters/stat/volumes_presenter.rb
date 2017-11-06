module Stat
  class VolumesPresenter < BasePresenter
    attr_reader :orders, :volume, :template

    def initialize(volume_with_orders)
      @volume = volume_with_orders.volume
      @orders = volume_with_orders.orders
      @template = orders.first.template
    end

    POINTS = {
      ETH: [0, 100, 150, 200, 300, 400, 500, 750, 1000, 1500, 2000, 3000, 4000, 5000, 10000, 10000000],
      BTC: [0, 10, 15, 20, 25, 30, 40, 50, 75, 100, 150, 200, 300, 400, 500, 1000, 10000000]
    }

    def self.to_csv(options={})
      buy_orders = options[:instances].where(type: 'buy')
      volumes = buy_orders.pluck(:volume)
      steps = POINTS[options[:currency].to_sym]
      volumes_objects = []
      chain_ids = buy_orders.pluck(:chain_id).uniq
      steps.each_with_index do |step, i|
        next_step = steps[i+1]
        if next_step
          orders = options[:instances].where("volume > ? AND volume < ?", step, next_step).where(chain_id: chain_ids)
          volumes_objects << Struct.new(:volume, :orders).new(step, orders) if orders.any?
        end
      end
      super(headers: false, instances: volumes_objects)
    end

    def spreadsheet_columns
      data = [
        ['Volumes', volume ],
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
      nil
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

    def avarage
      good_orders = orders.find_all {|o| o.created_at && o.closed_at}
      diffs = good_orders.map {|o| (o.closed_at - o.created_at).abs}.inject(&:+)
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
