class Poloniex::Market < ::Poloniex::Base
  class << self
    def create!(params={})
      action = params["type"]

      answer = client.post(api_path, action, {
        currencyPair: params["sign"],
        amount: params["volume"],
        rate: params["price"]
      })
      result = {"uuid" => answer["orderNumber"]}

      if block_given?
        yield result
      else
        result
      end
    end

    def api_path
      'tradingApi'
    end
  end
end
