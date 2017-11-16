module Candles
  class SaveProvider
    attr_reader :provider, :summaries, :provider_name

    def initialize(provider_name)
      @provider_name = provider_name
      @provider = Rails.const_get(provider_name.classify).new
      @summaries = provider.summaries.all
    end

    def call
      summaries.each do |summary|
        attrs = {
          provider: provider_name,
          max: summary.high,
          min: summary.low,
          market: summary.market,
          ask: summary.ask,
          bid: summary.bid,
        }
        Candle.create!(attrs)
      end
    end
  end
end
