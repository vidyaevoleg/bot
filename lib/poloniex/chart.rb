class Poloniex::Chart < ::Poloniex::Base
  attr_reader :market, :open, :low, :high, :close, :volume, :timestamp

  def initialize(attrs = {})
    @market = attrs["market"]
    @open =  attrs["open"].to_f,
    @low =  attrs["low"].to_f,
    @high =  attrs["high"].to_f,
    @close =  attrs["close"].to_f,
    @volume =  attrs["volume"].to_f,
    @timestamp =  attrs["date"]
  end

  class << self
    def find(currency, second_currency, interval = 5)
      market_name = "#{currency}_#{second_currency}"
      charts = client.get(api_path, api_command, {
        currencyPair: market_name,
        period: tick_interval_name(interval),
        end: 9999999999,
        start: (Time.now - 2.days).to_i
      })
      charts.map do |chart|
        new(chart.merge("market" => market_name))
      end
    end

    alias_method :all, :find
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
    'public'
  end

  def self.api_command
    'returnChartData'
  end

end
