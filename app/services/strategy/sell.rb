class Strategy::Sell < Strategy

  def call
    summaries.each do |summary|
      fix(summary)
    end
    summaries.each do |summary|
      panic_sell(summary)
    end
    perform_next_run
    perform_check
    save_last_call
  end


  def fix(summary)
    wallet = summary.wallet
    if wallet && wallet.available_currency(currency) > 0 && wallet.available_currency(currency) < MIN_TRADE_VOLUME
      Actions::BuyMore.new(summary, template, used_balance, full_balance).call do |*args|
        new_order(*args)
      end
    end
  end


  def panic_sell(summary)
    wallet = summary.wallet
    if wallet && wallet.available_currency(currency) > MIN_TRADE_VOLUME
      Actions::PanicSell.new(summary, wallet).call do |*args|
        new_order(*args)
      end
    end
  end
end
