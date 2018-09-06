module Candles
  class Save
    attr_reader :provider, :summaries, :provider_name

    def initialize(provider_name = 'bittrex')
      @provider_name = provider_name
      @provider = Rails.const_get(provider_name.classify).new
      @summaries = provider.summaries.all
    end

    def call
      Candle.where("created_at < ?", 1.hour.ago).destroy_all
      summaries.each do |summary|
        attrs = {
          provider: provider_name,
          max: summary.high,
          min: summary.low,
          market: summary.market,
          ask: summary.ask,
          bid: summary.bid,
        }
        Candle.create!(attrs) if summary.ask && summary.bid
      end
    end
  end
end
