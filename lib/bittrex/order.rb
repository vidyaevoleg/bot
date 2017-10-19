class Bittrex::Order < ::Bittrex::Base
  attr_reader :type, :id, :market, :price, :quantity, :remaining,
    :total, :fill, :executed_at, :raw, :closed_at, :commission, :attrs

  def initialize(attrs = {})
    @attrs = attrs
    @id = attrs['Id'] || attrs['OrderUuid']
    @type = (attrs['Type'] || attrs['OrderType']).to_s.split('_').last.downcase
    @market = attrs['Exchange']
    @quantity = quantity
    @price = attrs['PricePerUnit']
    @commission = attrs['CommissionPaid'] || attrs['CommissionReserved']
    @closed_at = attrs['Closed'] && Time.parse(attrs['Closed'])
  end

  def quantity
    attrs['Quantity'] - attrs['QuantityRemaining']
  end

  def part?
    attrs['QuantityRemaining'] > 0
  end

  def full
    self.class.find(id)
  end

  class << self
    def book(market, type, depth = 50)
      orders = []

      if type.to_sym == :both
        orderbook(market, type.downcase, depth).each_pair do |type, values|
          values.each do |data|
            orders << Bittrex::Order::Item.new(data.merge('Type' => type))
          end
        end
      else
        orderbook(market, type.downcase, depth).each do |data|
          orders << Bittrex::Order::Item.new(data.merge('Type' => type))
        end
      end
      orders
    end

    def api_path
      'account/getorderhistory'
    end

    def all(market = nil)
      if market
        client.get(api_path, {
          market: market
        })
      else
        super()
      end
    end

    def find(id)
      answer = client.get('account/getorder', {
        uuid: id
      })
      new(answer)
    end

    def opened
      client.get('market/getopenorders').map { |data|
        new(data)
      }
    end

    def orderbook(market, type, depth)
      client.get('public/getorderbook', {
        market: market,
        type: type,
        depth: depth
      })
    end
  end

  def buy?
    type == "buy"
  end

  def sell?
    !buy?
  end

  def close!
    begin
      self.class.client.get('market/cancel', {
        uuid: id
      })
    rescue RuntimeError => e
      puts "#{e} #{market}".red
    end
  end
end
