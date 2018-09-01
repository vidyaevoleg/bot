class Strategy::DealsVolume < Strategy::Default
  def buy_conditions
    [!big_sell_order?, !good_history?]
  end

end
