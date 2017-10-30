class Poloniex::Chart < ::Poloniex::Base
  attr_reader :market, :data

  def initialize(market, attrs = {})

    @market = market
    @data = attrs.map { |el|
      {
        open: el["open"],
        low: el["low"],
        high: el["high"],
        close: el["close"],
        volume: el["volume"],
        timestamp: el["date"]
      }
    }
  end

  def self.find(market, interval = 5)
    new(market, client.get(api_path, api_command, {
      currencyPair: market,
      period: tick_interval_name(interval),
      end:9999999999,
      start: (Time.now - 2.days).to_i
    }, {}))
  end

  def self.tick_interval_name(interval)
    {
      "1" =>  60,
      "5" => 5 * 60,
      "30" => 30 * 60,
      "120" => 2 * 60 * 60,
      "day" => 24 * 60 * 60
    }[interval] || 300
  end

  def self.api_path
    ''
  end

  def self.api_command
    'returnChartData'
  end

end