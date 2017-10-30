class Bittrex::Chart < ::Bittrex::Base
  attr_reader :market, :data

  def initialize(attrs = {})

    @market = market
    @data = attrs.map { |el|
      {
        open: el['O'],
        low: el['L'],
        high: el['H'],
        close: el['C'],
        volume: el['V'],
        timestamp: Time.parse(el['T']).to_i
      }
    }
  end

  def self.find(market, interval = 5)
    new(market, client.get('pub/market/GetTicks', {
      marketName: market, 
      tickInterval: tick_interval_name(interval)
    }, {}, 'https://bittrex.com/Api/v2.0'))
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