class Strategy::Buy
  attr_reader :summary,
    :wallet,
    :account,
    :settings

  def initialize(summary, account)
    @account = account
    @settings = account.template
    @summary = summary
    @wallet = summary.wallet
  end

  def call
    return if summary.base_volume.to_f < settings.min_market_volume.to_f
    min_percent = settings.min_buy_percent_diff.to_d / 100.to_d
    min_diff = settings.min_buy_sth_diff.to_f * ::Strategy::STH.to_f

    condition1 = ((((summary.ask.to_d - ::Strategy::STH.to_d) - (summary.bid.to_d + ::Strategy::STH.to_d))) / (summary.bid.to_d + ::Strategy::STH.to_d)).to_f > min_percent
    condition2 = ((summary.ask.to_d - ::Strategy::STH.to_d) - (summary.bid.to_d + ::Strategy::STH.to_d)).to_f > min_diff

    if condition1 && condition2
      yield(summary, 'buy', order_volume, order_rate, Order.reasons[:future])
    end
  end

  private

  def order_rate
    (summary.bid.to_d + ::Strategy::STH.to_d).to_f
  end

  def order_volume
    (settings.min_buy_price.to_d / order_rate.to_d).to_f
  end
end
