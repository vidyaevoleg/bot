module Actions
  class Buy < Base
    attr_reader :used_balance,
      :max_balance,
      :candles

    def initialize(summary, template, used_balance, max_balance)
      super
      @candles = Candle.where(provider: template.account.provider, market: summary.market).order(id: :desc).limit(10)
    end

    def call
      [market_active?, valid_spread?, valid_spread_percent?, valid_candles? ].each_with_index do |condition, i|
        unless condition
          puts "#{i} invalid condition on #{summary.market}".red unless i == 0
          return
        end
      end
      puts "order sum #{summary.volume * summary.rate}".green
      yield(summary, 'buy', summary.volume, summary.rate, Order.reasons[:future])
    end

    private

    def valid_spread_percent?
      # проверяем спред в процентах
      min_percent = template.min_buy_percent_diff.to_d / 100.to_d
      spread_diff = ((summary.ask.to_d - STH.to_d) / (summary.bid.to_d + STH.to_d))
      puts "spread diff #{spread_diff}, need #{1 + min_percent}"
      spread_diff > 1 + min_percent
    end

    def valid_candles?
      # проверяем спред в сатоши
      last_candle = candles.first
      other_candles = candles.reverse.first(5)
      # avg = other_candles.map(&:ask).inject(&:+) / other_candles.size
      last_candle.ask > other_candles.map(&:ask).max
      # last_candle.ask > avg
      # return true
    end


    #
    def valid_spread?
      # проверяем спред в пределах разумного
      summary.spread > (template.min_buy_percent_diff / 100) && summary.spread < (template.max_buy_percent_diff / 100)
    end

    def in_black_list?
      template.black_list.include?(summary.market)
    end

  end
end
