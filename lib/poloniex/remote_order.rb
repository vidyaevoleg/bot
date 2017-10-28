class Poloniex::RemoteOrder < ::Poloniex::Base
  attr_reader :uuid, :attrs, :id, :uuid, :market,
    :quantity, :price, :commission, :closed_at, :type

  def initialize(attrs = {})
    @attrs = attrs
    @uuid = attrs['orderNumber']
    @id = uuid
    @type = attrs['type']
    @market = attrs['market']
    @quantity = quantity
    @price = attrs['rate'].to_f
    @commission = attrs['fee'].to_f * quantity.to_f * price.to_f
    @closed_at = closed_at
  end

  def self.all
    result = client.post(api_path, 'returnTradeHistory', {currencyPair: 'all'})
    populize(result)
  end

  def self.find(uuid)
    opened.find {|o| o.id == uuid} || all.find {|o| o.id == uuid}
  end

  def self.opened
    result = client.post(api_path, 'returnOpenOrders', {currencyPair: 'all'})
    populize(result)
  end

  def self.populize(result)
    result.map do |k,v|
      orders = v
      if orders.any?
        orders.map do |order|
          one = {market: k}
          one.merge!(order)
          new(one.with_indifferent_access)
        end
      end
    end.compact.flatten
  end

  def self.api_path
    'tradingApi'
  end

  def self.api_method
    :post
  end

  def closed_at
    completed? ? Time.zone.now : nil
  end

  def quantity
    completed? ? attrs["amount"].to_f : attrs["startingAmount"].to_f
  end

  def completed?
    !attrs["startingAmount"]
  end

  def close!
    begin
      self.class.client.post(self.class.api_path, 'cancelOrder', {
        orderNumber: uuid
      })
    rescue RuntimeError => e
      puts "#{e} #{market}".red
    end
  end
end
