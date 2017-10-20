class AccountTemplateSerializer < ApplicationSerializer
  attributes :min_market_volume,
    :min_sell_percent_diff,
    :min_sell_percent_stop,
    :min_buy_sth_diff,
    :min_buy_percent_diff,
    :min_buy_price,
    :min_pump_risk_percent,
    :interval,
    :white_list_coef,
    :black_list,
    :white_list,
    :coins

  def coins
    Rails.cache.read(object.account.coins_cache_key)
  end
end
