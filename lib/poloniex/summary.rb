class Poloniex::Summary < ::Poloniex::Base
  attr_reader :market, :volume, :last, :base_volume, :ask, :bid, :buy_count, :sell_count, :yesterday_price

  attr_accessor :wallet

  def initialize(attrs = {})
    @market = attrs['MarketName']
    @volume = attrs['quoteVolume'].to_f
    @last = attrs['last'].to_f
    @base_volume = attrs['baseVolume'].to_f
    @bid = attrs['highestBid'].to_f
    @ask = attrs['lowestAsk'].to_f
    @buy_count = nil
    @sell_count = nil
    @yesterday_price = nil
  end

  def self.all
    result = client.get(api_path, api_command)
    result.map do |k,v|
      v['MarketName'] = k
      new(v)
    end
  end

  def self.api_path
    'public'
  end

  def self.api_command
    'returnTicker'
  end

  def self.api_method
    :get
  end

  def spread
    answer = ((ask.to_d - bid.to_d) / bid.to_d).to_f
    answer.nan? ? 0 : answer
  end
end
