class AccountTemplateSerializer < ApplicationSerializer
  attributes :id,
    :min_market_volume,
    :min_sell_percent_diff,
    :min_sell_percent_stop,
    :min_buy_percent_diff,
    :min_buy_price,
    :coins,
    :interval,
    :currency,
    :strategy,
    :need_restart,
    :max_buy_percent_diff,

  def need_restart
    object.off?
  end

  def coins
    Rails.cache.read(object.coins_cache_key)
  end
end
