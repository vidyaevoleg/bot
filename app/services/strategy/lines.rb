class Strategy::Lines < Strategy
  def buy_conditions
    [market_active?, valid_spread?, valid_spread_percent?, lineup?]
  end

  def lineup?
    answer = checked_minimum?
    answer
  end

  def checked_minimum?
    coefs.last(3) == coefs.last(3).sort && coefs.first < 0 && coefs.last > 0
  end

  def global_trend?
    line_coef(minimums) > 0
  end

  def coefs
    groups.map do |group|
      data_coef(group)
    end
  end

  def groups
    candles.last(candles.size - candles.size % group_size).each_slice(group_size)
  end

  def group_size
    20 # 10 minutes
  end

  def minimums
    groups.map {|group| group.map(&:ask).min}
  end

  def maximums
    groups.map {|group| group.map(&:ask).max}
  end

  def groups_count
    candles.size / group_size
  end

  def last_group
    candles.last(group_size)
  end

  def candles
    @candles ||= Candle.where(market: summary.market, provider: account.provider)
      .order(id: :desc).limit(nums).reverse
  end

  def nums
    minutes = 240
    minutes * 2
  end

  def data_coef(data)
    linefit = LineFit.new
    data = data.sort {|a, b| a.created_at.to_i <=> b.created_at.to_i }
    x = data.map(&:created_at).map(&:to_i)
    y = data.map(&:ask).map(&:to_f)
    linefit.setData(x,y)
    linefit.coefficients[1]
  end

  def line_coef(ar)
    linefit = LineFit.new
    x = []
    y = []
    ar.each_with_index do |a, i|
      x << i
      y << a
    end
    linefit.setData(x,y)
    linefit.coefficients[1]
  end
end
