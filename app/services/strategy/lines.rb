class Strategy::Lines < Strategy
  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?, lineup?]
  end

  def lineup?
    candles = Candle.where(market: summary.market, provider: account.provider)
      .where("created_at > ?", 15.minutes.ago).order(id: :desc)
    groups = [candles.last(5), candles.last(10).first(5), candles.first(5)]
    coefs = groups.map {|group| line_coef(group)}
    coefs.last == coefs.max
  end

  def line_coef(data)
    linefit = LineFit.new
    x = data.map(&:created_at).map(&:to_i)
    y = data.map(&:bid).map(&:to_f)
    linefit.setData(x,y)
    linefit.coefficients[0]
  end
end
