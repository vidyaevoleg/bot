class Strategy::TrendTrade < Strategy

	TREND = {
		INTERVAL_IN_MINUTES: 5,
		LAST_TWO_INTERVALS: 10,
		LAST_INTERVAL: 5
	}

	def call
    # base_to_fiat_trend = client.charts.find("#{template.usd_string}-#{template.currency}")
		base_to_fiat_trend = client.charts.find("USDT", template.currency, TREND[:INTERVAL_IN_MINUTES])
		@base_to_fiat_trend_values = base_to_fiat_trend.map(&:close)
    super
  end


  def start(summary)
    return if our_currencies.include?(summary.market)
    wallet = summary.wallet

		currencies = summary.market.split(/\-|\_/)
		currencies.delete(template.currency)
		second_currency = currencies[0]

		return if second_currency == 'USDT'

    currency_to_base_trend_values = client.charts.find(template.currency, second_currency, TREND[:INTERVAL_IN_MINUTES]).map(&:close)

    if trend_up?(@base_to_fiat_trend_values, TREND[:LAST_TWO_INTERVALS]) # тренд падает
	    if wallet && wallet.available_currency(currency) > MIN_TRADE_VOLUME
	      Actions::Sell.new(summary, template).call do |*args|
	        new_order(*args)
	      end
	    else
				if trend_up?(currency_to_base_trend_values)
					# если растет тренд текущая/базовая то
					# покупаем текущую,
					# можно убрать и отталкиваться только от базовая/фиат
		      Actions::Buy.new(summary, template, used_balance, full_balance).call do |*args|
		        new_order(*args)
		      end
				end
	    end
    else
    	# если тренд базовая/фиату растет
    	# и если падает тренд текущая/базовая то продаемся
    	if trend_up?(currency_to_base_trend_values)
		  	if wallet && wallet.available_currency(currency) > MIN_TRADE_VOLUME
		      Actions::PanicSell.new(summary, wallet, template).call do |*args|
		        new_order(*args)
		      end
		    end
    	end
	    # хз может быть можно не покупать в таком случае
	    #
	    # else
	    #   Actions::Buy.new(summary, template, used_balance, full_balance).call do |*args|
	    #     new_order(*args)
	    #   end
	    # end
    end
  end

  def trend_up?(trend_values, minutes = TREND[:LAST_INTERVAL])
		array = trend_values.last((minutes / TREND[:INTERVAL_IN_MINUTES]) + 1)
		array.last - array.first > 0
  end
end
