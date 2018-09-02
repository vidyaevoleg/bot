class Strategy::Default < Strategy

  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?, fast_grow?]
  end

  def market_active?
    summary.base_volume.to_f > template.min_market_volume.to_f
  end

  def valid_spread_percent?
    # проверяем спред в процентах
    min_percent = template.min_buy_percent_diff.to_d / 100.to_d
    spread_diff = ((summary.ask.to_d - STH.to_d) / (summary.bid.to_d + STH.to_d))
    puts "spread diff #{spread_diff}, need #{1 + min_percent}"
    spread_diff > 1 + min_percent
  end

  def fast_grow?
    candles = Candle.where(provider: template.account.provider, market: summary.market).order(id: :desc).limit(7)
    last_candle = candles.first
    other_candles = candles.reverse.first(6)
    # avg = other_candles.map(&:ask).inject(&:+) / other_candles.size
    last_candle.ask > other_candles.map(&:ask).max
    # last_candle.ask > avg
    # return true
  end

  def valid_spread?
    # проверяем спред в пределах разумного
    summary.spread > (template.min_buy_percent_diff / 100) && summary.spread < (template.max_buy_percent_diff / 100)
  end


end
