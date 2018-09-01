module Validations
  class CheckHistory
    attr_reader :market, :provider

    def initialize(template, market)

    end

    def call
      true
    end

  end
end
