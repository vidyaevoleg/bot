class AccountTemplateSerializer < ApplicationSerializer
  attributes :id,
    :min_market_volume,
    :min_sell_percent_diff,
    :min_sell_percent_stop,
    :min_buy_sth_diff,
    :min_buy_percent_diff,
    :min_buy_price,
    :min_pump_risk_percent,
    :white_list_coef,
    :black_list,
    :white_list,
    :coins,
    :interval,
    :currency,
    :strategy,
    :need_restart,
    :max_buy_percent_diff,
    :white_spread_percent_max,
    :white_spread_percent_min

  def need_restart
    object.off?
  end

  def coins
    Rails.cache.read(object.coins_cache_key)
  end
end
