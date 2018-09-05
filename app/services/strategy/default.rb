class Strategy::Default < Strategy

  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?]
  end

  def market_active?
    summary.base_volume.to_f > template.min_market_volume.to_f
  end

  def valid_spread_percent?
    # проверяем спред в процентах
    summary.spread > (template.min_buy_percent_diff / 100) && summary.spread < (template.max_buy_percent_diff / 100)
  end

  def fast_grow?
    candles = Candle.where(provider: template.account.provider, market: summary.market).order(id: :desc).limit(6)
    last_candle = candles.first
    other_candles = candles.reverse.first(5)
    # avg = other_candles.map(&:ask).inject(&:+) / other_candles.size
    last_candle.ask > other_candles.map(&:ask).max
    # last_candle.ask > avg
    # return true
  end
end
