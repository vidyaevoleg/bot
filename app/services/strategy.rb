class Strategy
  attr_reader :summary, :template, :wallet, :balance, :currency

  def initialize(summary, template, balance)
    @template = template
    @summary = summary
    @balance = balance
    @wallet = summary.wallet
    @currency = template.currency
  end

  def call(&block)
    summary.class.module_eval { attr_accessor :rate, :volume}
    summary.rate = rate
    summary.volume = volume

    if summary.wallet
      try_to_sell{ |*args| yield(*args) }
    else
      try_to_buy { |*args| yield(*args) }
    end
  end

  def try_to_sell
    available_currency = wallet.available_currency(currency)
    min_trade_volume =  summary.bid * template.min_buy_price
    if available_currency > 0 && available_currency < min_trade_volume
      try_to_buy if enough?
    elsif available_currency >= min_trade_volume
      Actions::Sell.new(summary, template).call do |*args|
        yield(*args)
      end
    end
  end

  def try_to_buy
    return if buy_conditions.include?(false)
    yield(summary, 'buy' ,Order.reasons[:profit])
  end

  def buy_conditions
    [enough?]
  end

  def sell_conditions
    []
  end

  def enough?
    balance > summary.rate * summary.volume
  end

  def volume
    wallet ? wallet.available :  (template.min_buy_price.to_d / summary.rate.to_d).to_f
  end

  def rate
    wallet ? (summary.ask.to_d - STH.to_d).to_f : (summary.bid.to_d + STH.to_d).to_f
  end
end
