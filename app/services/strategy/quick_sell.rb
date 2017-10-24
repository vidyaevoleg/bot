class Strategy::QuickSell < Strategy
  def start(summary)
    return if our_currencies.include?(summary.market)
    wallet = summary.wallet
    if wallet && wallet.available_currency(currency) > MIN_TRADE_VOLUME
      Actions::QuickSell.new(summary, template).call do |*args|
        new_order(*args)
      end
    else
      Actions::Buy.new(summary, template, used_balance, full_balance).call do |*args|
        new_order(*args)
      end
    end
  end
end
