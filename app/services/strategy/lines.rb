class Strategy::Lines < Strategy
  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?, lineup?]
  end

  def lineup?
    candles = Candle.where(market: summary.market, provider: account.provider)
    short = candles.where("created_at > ?", 5.minutes.ago)
    long = candles
    line_coef(long) > 0 && line_coef(short) > 0
  end

  def line_coef(data)
    linefit = LineFit.new
    x = data.map(&:created_at).map(&:to_i)
    y = data.map(&:bid).map(&:to_f)
    linefit.setData(x,y)
    linefit.coefficients[0]
  end
end
