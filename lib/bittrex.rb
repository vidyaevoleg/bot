class Bittrex
  autoload :Base, 'bittrex/base'
  autoload :Market, 'bittrex/market'
  autoload :Currency, 'bittrex/currency'
  autoload :Deposit, 'bittrex/deposit'
  autoload :Order, 'bittrex/order'
  autoload :Item, 'bittrex/order/item'
  autoload :Ticker, 'bittrex/ticker'
  autoload :Summary, 'bittrex/summary'
  autoload :Wallet, 'bittrex/wallet'
  autoload :Withdrawal, 'bittrex/withdrawal'

  attr_reader :client, :key, :secret

  def initialize(auth={})
    @key = auth[:key]
    @secret = auth[:secret]
    @client = Bittrex::Client.new(auth)
    add_methods
  end

  METHODS_MAP = {
    markets: Market,
    currencies: Currency,
    deposits: Deposit,
    orders: Order,
    base: Base,
    tickers: Ticker,
    summaries: Summary,
    wallets: Wallet,
    withdrawals: Withdrawal
  }

  def add_methods
    Base.cattr_accessor(:client)
    Base.client = client
    METHODS_MAP.each do |key, value|
      define_singleton_method(key) do
        value
      end
    end
  end

  private

end
