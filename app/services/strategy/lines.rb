class Strategy::Lines < Strategy
  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?, lineup?]
  end

  def lineup?
    answer = coefs.last(3) == coefs.last(3).sort &&
      coefs.select {|c| c < 0}.any? &&
      coefs.last > 0
    answer
  end

  def global_trend?
    line_coef(candles) > 0
  end

  def coefs
    size = 30
    coefs = candles.last(candles.size - candles.size % size).each_slice(size).map do |group|
      line_coef(group)
    end
  end

  def candles
    @candles ||= Candle.where(market: summary.market, provider: account.provider)
      .order(id: :desc).limit(nums).reverse
  end

  def nums
    minutes = 240
    minutes * 2
  end

  def line_coef(data)
    linefit = LineFit.new
    data = data.sort {|a, b| a.created_at.to_i <=> b.created_at.to_i }
    x = data.map(&:created_at).map(&:to_i)
    y = data.map(&:ask).map(&:to_f)
    linefit.setData(x,y)
    linefit.coefficients[1]
  end
end
