class Bittrex::Wallet < ::Bittrex::Base
  attr_reader :id, :currency, :balance, :available, :pending, :address, :requested, :raw,
    :available_btc, :balance_btc

  def initialize(attrs = {})
    @id = attrs['Uuid'].to_s
    @address = attrs['CryptoAddress']
    @currency = attrs['Currency']
    @balance = attrs['Balance']
    @balance_btc = to_btc(balance)
    @available = attrs['Available']
    @available_btc = to_btc(available)
    @pending = attrs['Pending']
    @raw = attrs
    @requested = attrs['Requested']
  end

  def self.api_path
    'account/getbalances'
  end

  def sign
    "BTC-#{currency}"
  end

  def summary
    @_summary ||= Bittrex::Summary.all.find {|s| s.market == sign}
  end

  private

  def btc?
    currency == 'BTC'
  end

  def usd?
    currency == 'USDT'
  end

  def to_btc(sum)
    return 0 if sum == 0

    if btc?
      sum
    elsif usd?
      0
    else
      unless summary
        raise "NO summary FOR #{sign}"
      end
      sum * summary.last
    end
  end
end
