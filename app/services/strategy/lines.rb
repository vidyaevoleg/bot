class Strategy::Lines < Strategy
  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?, lineup?]
  end

  def lineup?

    candles = Candle.where(market: summary.market, provider: account.provider)
      .where("created_at > ?", 15.minutes.ago).order(id: :desc)
    nums = 10
    groups = [candles.last(nums), candles.last(nums).first(nums), candles.first(nums)]
    coefs = groups.map {|group| line_coef(group)}
    coefs.last == coefs.max && coefs.last > 0
  end

  def line_coef(data)
    linefit = LineFit.new
    data = data.sort {|a, b| a.created_at.to_i <=> b.created_at.to_i }
    x = data.map(&:created_at).map(&:to_i)
    y = data.map(&:bid).map(&:to_f)
    linefit.setData(x,y)
    linefit.coefficients[0]
  end
end
