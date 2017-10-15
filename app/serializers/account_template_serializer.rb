class AccountTemplateSerializer < ApplicationSerializer
  attributes :min_market_volume,
    :min_sell_percent_diff,
    :min_sell_percent_stop,
    :min_buy_sth_diff,
    :min_buy_percent_diff,
    :min_buy_price,
    :min_pump_risk_percent,
    :interval
end
