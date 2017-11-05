class Bittrex::Wallet < ::Bittrex::Base
  attr_reader :id, :currency, :balance, :available, :pending, :address, :requested, :raw

  def initialize(attrs = {})
    @id = attrs['Uuid'].to_s
    @address = attrs['CryptoAddress']
    @currency = attrs['Currency']
    @balance = attrs['Balance']
    @available = attrs['Available']
    @pending = attrs['Pending']
    @raw = attrs
    @requested = attrs['Requested']
    @cache = {}
  end

  def self.api_path
    'account/getbalances'
  end

  def sign(second_currency)
    signs(second_currency).first
  end

  def signs(second_currency)
    ["#{second_currency}-#{currency}", "#{currency}-#{second_currency}"]
  end

  def summary(second_currency = nil)
    if second_currency
      cache_key = "#{second_currency}-#{currency}"
      if @cache[cache_key]
        @cache[cache_key]
      else
        @_summary = Bittrex::Summary.all.find {|s| signs(second_currency).include?(s.market)}
      end
    else
      @_summary
    end
  end

  def available_currency(second_currency = nil)
    return 0 if balance == 0
    _summary = summary(second_currency)

    if !_summary
      if second_currency == currency
        available
      else
        0
      end
    elsif usd?
      0
    else
      reverse = _summary.market.split('-').first == currency
      reverse ? (available / _summary.last) : (available * _summary.last)
    end
  end

  private

  def usd?
    currency == 'USDT'
  end

end
