class Strategy::DealsVolume < Strategy::Default
  def buy_conditions
    [not_enough?, !big_sell_order?, !good_history?]
  end

end
