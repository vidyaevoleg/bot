class Poloniex::Wallet < ::Poloniex::Base
  attr_reader :id, :currency, :balance, :available, :pending, :raw, :balance_btc

  def initialize(attrs = {})
    @currency = attrs['currency']
    @available = attrs['available'].to_f
    @pending = attrs['onOrders'].to_f
    @balance_btc = attrs['btcValue'].to_f
    @raw = attrs
    @cache = {}
  end

  def self.api_path
    'tradingApi'
  end

  def self.api_command
    'returnCompleteBalances'
  end

  def self.all
    result = client.post(api_path, api_command)
    result.map do |k,v|
      v['currency'] = k
      new(v)
    end
  end

  def sign(second_currency)
    "#{second_currency}_#{currency}"
  end

  def summary(second_currency = nil)
    if second_currency
      cache_key = "#{second_currency}-#{currency}"
      if @cache[cache_key]
        @cache[cache_key]
      else
        @_summary = Poloniex::Summary.all.find {|s| s.market == sign(second_currency)}
      end
    else
      @_summary
    end
  end

  def available_currency(second_currency = nil)
    return 0 if balance == 0
    _summary = summary(second_currency)

    if !summary
      0
    elsif usd?
      0
    else
      available * _summary.last
    end
  end

  private

  def usd?
    currency == 'USDT'
  end

end
