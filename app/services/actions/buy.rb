module Actions
  class Buy
    attr_reader :summary,
      :template,
      :used_balance,
      :max_balance,
      :candles

    def initialize(summary, template, used_balance, max_balance)
      @template = template
      @summary = summary
      @used_balance = used_balance
      @max_balance = max_balance
      @candles = Candle.where(provider: template.account.provider, market: summary.market).order(id: :desc).limit(10)
    end

    def call
      [condition0, condition1, condition2, condition3].each_with_index do |condition, i|
        unless condition
          puts "#{i} invalid condition on #{summary.market}".red unless i == 0
          return
        end
      end
      puts "order sum #{order_volume * order_rate}".green
      yield(summary, 'buy', order_volume, order_rate, Order.reasons[:future])
    end

    private

    def condition0
      summary.base_volume.to_f > template.min_market_volume.to_f
    end

    def condition1
      # проверяем спред в процентах
      min_percent = template.min_buy_percent_diff.to_d / 100.to_d
      spread_diff = ((summary.ask.to_d - ::Strategy::STH.to_d) / (summary.bid.to_d + ::Strategy::STH.to_d))
      puts "spread diff #{spread_diff}, need #{1 + min_percent}"
      spread_diff > 1 + min_percent
    end

    # def condition2
    #   # проверяем спред в сатоши
    #   min_diff = template.min_buy_sth_diff.to_d * ::Strategy::STH.to_d
    #   ((summary.ask.to_d - ::Strategy::STH.to_d) - (summary.bid.to_d + ::Strategy::STH.to_d)) > min_diff
    # end

    def condition2
      # проверяем спред в сатоши
      last_candle = candles.first
      other_candles = candles.reverse.first(5)
      # avg = other_candles.map(&:ask).inject(&:+) / other_candles.size
      last_candle.ask > other_candles.map(&:ask).max
      # last_candle.ask > avg
      # return true
    end

    # def condition3
    #   # проверяем что не в черном списке
    #   !in_black_list?
    # end
    #
    def condition3
      # проверяем доступный баланс
      used_balance + (order_rate * order_volume) < max_balance
    end
    #
    # def condition5
    #   # проверяем спред в пределах разумного
    #   byebug
    #   summary.spread > (template.min_buy_percent_diff / 100) && summary.spread < (template.max_buy_percent_diff / 100)
    # end

    def in_black_list?
      template.black_list.include?(summary.market)
    end

    def order_rate
      (summary.bid.to_d + ::Strategy::STH.to_d).to_f
    end

    def in_white_list?
      white_spread = (summary.spread > (template.white_spread_percent_min / 100)) && (summary.spread < (template.white_spread_percent_max / 100))
      template.white_list.include?(summary.market) || white_spread
    end

    def order_volume
      default_volume = (template.min_buy_price.to_d / order_rate.to_d).to_f
      if in_white_list?
        default_volume * template.white_list_coef.to_f
      else
        default_volume
      end
    end
  end
end
