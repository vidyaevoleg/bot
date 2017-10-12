class Bittrex::Market < ::Bittrex::Base
  attr_reader :name, :currency, :base, :currency_name, :base_name, :minimum_trade, :active, :created_at, :raw

  def initialize(attrs = {})
    @name = attrs['MarketName']
    @currency = attrs['MarketCurrency']
    @base = attrs['BaseCurrency']
    @currency_name = attrs['MarketCurrencyLong']
    @base_name = attrs['BaseCurrencyLong']
    @minimum_trade = attrs['MinTradeSize']
    @active = attrs['IsActive']
    @created_at = Time.parse(attrs['Created'])
    @raw = attrs
  end

  class << self

    def create!(params={})
      action = params["type"] == 'buy' ? 'market/buylimit' : 'market/selllimit'

      answer = client.get(action, {
        apikey: client.key,
        market: params["sign"],
        quantity: params["volume"],
        rate: params["price"]
      })
      if block_given?
        yield answer
      else
        answer
      end
    end

    def api_path
      'public/getmarkets'
    end

  end


end


  # def go
  #   wallet = Bittrex::Wallet.all.find {|w| w.sign == 'BTC-KMD'}
  # def go
  #   ticker = Bittrex::Ticker.find('BTC-KMD')
  #   quantity = 19.94202319
  #   rate = ticker.bid || 0.00047621
  #   Bittrex::Market.create!('BTC-KMD', 'sell', quantity, rate)
  # end
  # end
