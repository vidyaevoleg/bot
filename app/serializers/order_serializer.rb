class OrderSerializer < ApplicationSerializer
  attributes :id, :market, :price, :quantity, :type,
    :commission, :reason, :profit, :volume, :spread,
    :sell_count, :buy_count, :yesterday_price

  def spread
    object.spread && object.spread.round(6) * 100
  end

  def volume
    object.volume && object.volume.round(6)
  end

  def profit
    object.profit && object.profit.round(8)
  end

end
