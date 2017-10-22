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

  def need_restart
    !object.last_time || (Time.zone.now - object.last_time > object.interval)
  end

  def coins
    Rails.cache.read(object.coins_cache_key)
  end
end
