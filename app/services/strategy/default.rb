class Strategy::Default < Strategy

  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?, fast_grow?]
  end

  def fast_grow?
    nums = 6
    candles = Candle.where(provider: template.account.provider, market: summary.market).order(id: :desc).limit(nums)
    last_candle = candles.first
    other_candles = candles.reverse.first(nums-1)
    # avg = other_candles.map(&:ask).inject(&:+) / other_candles.size
    if last_candle.min > other_candles.map(&:min).max && last_candle.max > other_candles.map(&:max).max
      puts "current #{last_candle.to_f} more then #{other_candles.map(&:to_f)}".green
      return true
    end
    # last_candle.ask > avg
    # return true
  end
end
