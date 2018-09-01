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
    if available_currency > 0 && available_currency < min_trade_volume
      buy_more { |*args| yield(*args) }
    elsif available_currency >= min_trade_volume
      Actions::Sell.new(summary, template).call do |*args|
        yield(*args)
      end
    end
  end

  def try_to_buy
    yield(summary, 'buy' , Order.reasons[:profit]) if buy?
  end

  def buy_more
    yield(summary, 'buy', Order.reasons[:buy_more]) if enough?
  end

  private

  def min_trade_volume
    summary.bid * template.min_buy_price
  end

  def available_currency
    wallet.available_currency(currency)
  end

  def enough?
    balance > summary.rate * summary.volume
  end

  def buy?
    buy_conditions.each_with_index do |condition, index|
      unless condition
        puts "invalid condition #{index}".yellow
        return false
      end
    end
    true
  end

  def volume
    if wallet
      if available_currency < min_trade_volume
        min_trade_volume
      else
        wallet.available
      end
    else
      (template.min_buy_price.to_d / summary.rate.to_d).to_f
    end
  end

  def rate
    wallet ? (summary.ask.to_d - STH.to_d).to_f : (summary.bid.to_d + STH.to_d).to_f
  end
end
