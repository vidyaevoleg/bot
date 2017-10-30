class Strategy::TrendTrade < Strategy

	def call
    # можно как то вытащить в настройки
    @trend_interval_in_minutes = 5
    
    # тренд по 5 минуткам
    # base_to_fiat_trend = client.chart.find("#{template.usd_string}-#{template.currency}")
    base_to_fiat_trend = client.chart.find("USDT-#{template.currency}", @trend_interval_in_minutes).data

		@base_to_fiat_trend_values = base_to_fiat_trend.map { |el|
			el[:close]
			# можно чтото смотреть еще с volume
		}

    super()
  end


  def start(summary)

    return if our_currencies.include?(summary.market)
    wallet = summary.wallet

    currency_to_base_trend_values = client.chart.find("USDT-#{template.currency}", @trend_interval_in_minutes).data.map { |el|
			el[:close]
		}

    if !check_trend_raising_in_minutes(@base_to_fiat_trend_values, 10)[:bool]
    	# если тренд базовая/фиат падает то 
    	# продаем с балансов и 
    	# проверяем тренд текущая/базовая для покупок
    	# 
	    if wallet && wallet.available_currency(currency) > MIN_TRADE_VOLUME

	      Actions::Sell.new(summary, template).call do |*args|
	        new_order(*args)
	      end

	    else

				if check_trend_raising_in_minutes(currency_to_base_trend_values, 5)[:bool]
					# если растет тренд текущая/базовая то
					# покупаем текущую, 
					# можно убрать и отталкиваться только от базовая/фиат
					# 
		      Actions::Buy.new(summary, template, used_balance, full_balance).call do |*args|
		        new_order(*args)
		      end

				end

	    end
    else 
    	# если тренд базовая/фиату растет
    	# и если падает тренд текущая/базовая то продаемся
    	# 
    	if !check_trend_raising_in_minutes(currency_to_base_trend_values, 5)[:bool]

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

  def check_trend_raising_in_minutes(trend_values, minutes)
  		array = trend_values.last((minutes / @trend_interval_in_minutes) + 1)
  		{
  			diff: array.last - array.first, 
  			bool: (array.last - array.first) >= 0
  		}
  end

  # def raising_day
  # 	check_trend_raising_in_minutes(24 * 60.to_i)
  # end

  # def raising_half_day
  # 	check_trend_raising_in_minutes(12 * 60.to_i)
  # end

  # def raising_last_hour
  # 	check_trend_raising_in_minutes(60)
  # end

  # def raising_last_half_hour
  # 	check_trend_raising_in_minutes(30)
  # end

  # def raising_15_min
  # 	check_trend_raising_in_minutes(15.to_f)
  # end

  # def raising_5_min
  # 	check_trend_raising_in_minutes(5.to_f)
  # end

end