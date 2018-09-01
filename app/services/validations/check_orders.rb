module Validations
  class CheckOrders
    attr_reader :market, :provider

    def initialize(market )

    end

    def call
      true
    end

  end
end
