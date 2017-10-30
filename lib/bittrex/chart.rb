class Bittrex::Chart < ::Bittrex::Base
  attr_reader :market, :open, :low, :high, :close, :volume, :timestamp

  def initialize(attrs = {})
    @market = attrs['market']
    @open =  attrs['O'],
    @low =  attrs['L'],
    @high =  attrs['H'],
    @close =  attrs['C'],
    @volume =  attrs['V'],
    @timestamp =  Time.parse(attrs['T']).to_i
  end

  class << self
    def find(currency, second_currency, interval = 5)
      market_name = "#{currency}-#{second_currency}"
      charts = client.get('pub/market/GetTicks', {
        marketName: market_name,
        tickInterval: tick_interval_name(interval)
      }, {}, 'https://bittrex.com/Api/v2.0')
      charts.map do |chart|
        new(chart.merge("market" => market_name))
      end
    end

    alias_method :all, :find
  end

  def self.tick_interval_name(interval)
    {
      "1" =>  "oneMin",
      "5" => "fiveMin",
      "30" => "thirtyMin",
      "60" => "hour",
      "day" => "day"
    }[interval] || "fiveMin"
  end

end
