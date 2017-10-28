class Bittrex::Market < ::Bittrex::Base
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
