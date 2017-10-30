module Stat
  class AllPresenter < BasePresenter
    attr_reader :order

    def initialize(order)
      @order = order
    end

    def spreadsheet_columns
      data = [
        ['Id', order.id],
        ['Opened date', order.created_at],
        ['Closed date', order.closed_at],
        ['Market', order.market],
        ['Action', order.type],
        ['Quantity', order.quantity],
        ['Price', order.price],
        ['Commission', order.commission],
        ['Reason', order.reason],
        ['Market volume', order.volume],
        ['Spread', order.spread],
        ['BTC value', order.quantity.to_f * order.price.to_f],
        ['Sell count', order.sell_count ],
        ['Buy count', order.buy_count],
        ['Chain id', order.chain_id],
        ['Yesterday price', order.yesterday_price],
        ['interval', order.template_data[:interval]],
        ['min_market_volume', order.template_data[:min_market_volume]],
        ['min_sell_percent_diff', order.template_data[:min_sell_percent_diff]],
        ['min_market_volume', order.template_data[:min_market_volume]],
        ['min_sell_percent_diff', order.template_data[:min_sell_percent_diff]],
        ['min_sell_percent_stop', order.template_data[:min_sell_percent_stop]],
        ['min_buy_sth_diff', order.template_data[:min_buy_sth_diff]],
        ['min_buy_percent_diff', order.template_data[:min_buy_percent_diff]],
        ['min_buy_price', order.template_data[:min_buy_price]],
        ['white_list_coef', order.template_data[:white_list_coef]],
        ['currency', order.template_data[:currency]],
        ['strategy', order.template_data[:strategy]]
      ]
      data
    end
  end
end
