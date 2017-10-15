class Strategy::BuyMore
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
    yield(summary, 'buy', order_volume, order_rate, Order.reasons[:buy_more])
  end

  private

  def order_rate
    (summary.bid.to_d + ::Strategy::STH.to_d).to_f
  end

  def order_volume
    sum = ::Strategy::MIN_TRADE_VOLUME
    (sum / order_rate.to_d).to_f
  end
end
