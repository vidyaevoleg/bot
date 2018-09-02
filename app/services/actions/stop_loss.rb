module Actions
  class StopLoss < Sell

    def call
      yield(summary, 'sell', price, volume, Order.reasons[:stop_loss])
    end

  end
end
