class Bittrex::Summary < ::Bittrex::Base
  attr_reader :market, :high, :low, :volume, :last, :base_volume, :raw, :created_at,
    :ask, :bid, :buy_count, :sell_count

  attr_accessor :wallet

  alias_method :vol, :volume
  alias_method :base_vol, :base_volume

  def initialize(attrs = {})
    @market = attrs['MarketName']
    @high = attrs['High']
    @low = attrs['Low']
    @volume = attrs['Volume']
    @last = attrs['Last']
    @base_volume = attrs['BaseVolume']
    @bid = attrs['Bid']
    @ask = attrs['Ask']
    @buy_count = attrs['OpenBuyOrders']
    @sell_count = attrs['OpenSellOrders']
    @raw = attrs
    @created_at  = Time.parse(attrs['TimeStamp'])
  end

  def self.api_path
    'public/getmarketsummaries'
  end

  def self.btc
    all.find_all {|s| s.market.include?('BTC-')}
  end

  def self.find(market)
    client.get('public/getmarketsummary', {
      market: market,
    })
  end

  def spread
    answer = ((ask.to_d - bid.to_d) / bid.to_d).to_f
    answer.nan? ? 0 : answer
  end
end
