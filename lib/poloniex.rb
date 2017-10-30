class Poloniex
  autoload :Base, 'poloniex/base'
  autoload :Order, 'poloniex/remote_order'
  autoload :Summary, 'poloniex/summary'
  autoload :Wallet, 'poloniex/wallet'
  autoload :Market, 'poloniex/market'
  autoload :Client, 'poloniex/client'
  autoload :Chart, 'poloniex/chart'

  attr_reader :client, :key, :secret

  def initialize(auth={})
    @key = auth[:key]
    @secret = auth[:secret]
    @client = ::Poloniex::Client.new(auth)
    add_methods
  end

  METHODS_MAP = {
    remote_orders: RemoteOrder,
    base: Base,
    summaries: Summary,
    wallets: Wallet,
    markets: Market,
    clients: Client,
    charts: Chart
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
