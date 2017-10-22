class Bittrex::Wallet < ::Bittrex::Base
  attr_reader :id, :currency, :balance, :available, :pending, :address, :requested, :raw, :balance_btc

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
    "#{second_currency}-#{currency}"
  end

  def summary(second_currency = nil)
    if second_currency
      cache_key = "#{second_currency}-#{currency}"
      if @cache[cache_key]
        @cache[cache_key]
      else
        @_summary = Bittrex::Summary.all.find {|s| s.market == sign(second_currency)}
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
      balance * summary.last
    end
  end

  private

  def usd?
    currency == 'USDT'
  end

end
