class Strategy::Sell < Strategy

  def call
    return if other_templates_running?
    perform_next_run
    summaries.each do |summary|
      next unless need_call?(summary)
      fix(summary)
      panic_sell(summary)
    end
    perform_check
    save_last_call
  end

  # точно такой же есть в базовой стратегии
  # наверное можно отсюда убрать
  #
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
      Actions::PanicSell.new(summary, wallet, template).call do |*args|
        new_order(*args)
      end
    end
  end
end
