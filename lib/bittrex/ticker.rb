class Bittrex::Ticker < ::Bittrex::Base
  attr_reader :market, :bid, :ask, :last, :raw

  def initialize(market, attrs = {})
    @market = market
    @bid = attrs['Bid']
    @ask = attrs['Ask']
    @last = attrs['Last']
    @raw = attrs
  end

  class << self
    undef :all

    def find(market)
      new(market, client.get('public/getticker', market: market))
    end
  end

  def summary
    @_summary ||= Summary.find(market)
  end

end
