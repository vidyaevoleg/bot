class Strategy::OnlySell < Strategy
  def call
    if summary.wallet
      try_to_sell { |*args| yield(*args) }
    end
  end
end
