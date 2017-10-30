class Bittrex
  autoload :Base, 'bittrex/base'
  autoload :Market, 'bittrex/market'
  autoload :Currency, 'bittrex/currency'
  autoload :Deposit, 'bittrex/deposit'
  autoload :Order, 'bittrex/remote_order'
  autoload :Item, 'bittrex/order/item'
  autoload :Ticker, 'bittrex/ticker'
  autoload :Summary, 'bittrex/summary'
  autoload :Wallet, 'bittrex/wallet'
  autoload :Withdrawal, 'bittrex/withdrawal'
  autoload :Client, 'bittrex/client'
  autoload :Chart, 'bittrex/chart'

  attr_reader :client, :key, :secret

  def initialize(auth={})
    @key = auth[:key]
    @secret = auth[:secret]
    @client = ::Bittrex::Client.new(auth)
    add_methods
  end

  def get(*args)
    client.get(*args)
  end

  METHODS_MAP = {
    markets: Market,
    currencies: Currency,
    deposits: Deposit,
    remote_orders: RemoteOrder,
    base: Base,
    charts: Chart,
    tickers: Ticker,
    summaries: Summary,
    wallets: Wallet,
    withdrawals: Withdrawal,
    clients: Client
  }

  def add_methods
    self.class.class_variable_set(:@@client, client)
    METHODS_MAP.each do |key, value|
      define_singleton_method(key) do
        value
      end
    end
  end

  def self.client
    @@client
  end

end
